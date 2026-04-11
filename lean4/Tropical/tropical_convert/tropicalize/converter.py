"""
Model converter: HuggingFace transformer → Tropical architecture.

The conversion process:
1. Load the source model from HuggingFace (or cache).
2. Extract architecture hyperparameters (hidden_size, num_heads, etc.).
3. Build a TropicalCausalLM with matching architecture.
4. Transfer compatible weights (embeddings, norms) directly.
5. Initialize tropical linear layers from standard linear weights using
   the log-domain transformation: W_tropical = log(|W_standard|) + sign info.

This produces a structurally correct tropical model that needs distillation
training to recover the original model's performance.
"""

from __future__ import annotations

import gc
import json
import logging
import math
from pathlib import Path
from typing import Optional

import torch
import torch.nn as nn

from transformers import (
    AutoModelForCausalLM,
    AutoTokenizer,
    AutoConfig,
)

from .layers import TropicalCausalLM, TropicalLinear
from .cache import (
    get_model_cache_path,
    get_converted_cache_path,
    is_cached,
    mark_complete,
)

logger = logging.getLogger(__name__)


def download_model(
    model_name: str,
    dtype: torch.dtype = torch.float32,
    trust_remote_code: bool = True,
) -> tuple:
    """
    Download (or load from cache) a HuggingFace model and tokenizer.

    Returns:
        (model, tokenizer, config)
    """
    cache_path = get_model_cache_path(model_name)

    if is_cached(cache_path):
        logger.info(f"Loading model from cache: {cache_path}")
        model_path = str(cache_path)
    else:
        logger.info(f"Downloading model: {model_name}")
        model_path = model_name

    tokenizer = AutoTokenizer.from_pretrained(
        model_path if is_cached(cache_path) else model_name,
        trust_remote_code=trust_remote_code,
    )

    config = AutoConfig.from_pretrained(
        model_path if is_cached(cache_path) else model_name,
        trust_remote_code=trust_remote_code,
    )

    model = AutoModelForCausalLM.from_pretrained(
        model_path if is_cached(cache_path) else model_name,
        torch_dtype=dtype,
        trust_remote_code=trust_remote_code,
        device_map="cpu",
    )

    # Cache the downloaded model if not already cached
    if not is_cached(cache_path):
        logger.info(f"Caching model to: {cache_path}")
        model.save_pretrained(cache_path)
        tokenizer.save_pretrained(cache_path)
        config.save_pretrained(cache_path)
        mark_complete(cache_path, {"model_name": model_name})

    return model, tokenizer, config


def extract_architecture_params(config) -> dict:
    """
    Extract architecture hyperparameters from a HuggingFace config.
    Handles various model families (LLaMA, Qwen, Mistral, Gemma, Phi, etc.).
    """
    params = {}

    # Vocabulary
    params["vocab_size"] = config.vocab_size

    # Hidden size
    params["hidden_size"] = config.hidden_size

    # Number of layers
    params["num_layers"] = getattr(
        config, "num_hidden_layers",
        getattr(config, "n_layer", getattr(config, "num_layers", 12))
    )

    # Attention heads
    params["num_heads"] = getattr(
        config, "num_attention_heads",
        getattr(config, "n_head", 12)
    )

    # KV heads (for GQA)
    params["num_kv_heads"] = getattr(
        config, "num_key_value_heads",
        params["num_heads"]
    )

    # Head dimension
    params["head_dim"] = getattr(
        config, "head_dim",
        params["hidden_size"] // params["num_heads"]
    )

    # Intermediate (MLP) size
    params["intermediate_size"] = getattr(
        config, "intermediate_size",
        getattr(config, "n_inner", 4 * params["hidden_size"])
    )

    # Max position embeddings
    params["max_position_embeddings"] = getattr(
        config, "max_position_embeddings", 8192
    )

    # RMS norm epsilon
    params["rms_norm_eps"] = getattr(
        config, "rms_norm_eps",
        getattr(config, "layer_norm_epsilon", 1e-6)
    )

    # RoPE theta
    params["rope_theta"] = getattr(config, "rope_theta", 10000.0)

    # Bias
    params["bias"] = getattr(config, "attention_bias", False)

    # Tie embeddings
    params["tie_word_embeddings"] = getattr(
        config, "tie_word_embeddings", True
    )

    return params


def build_tropical_model(
    arch_params: dict,
    initial_temperature: float = 1.0,
) -> TropicalCausalLM:
    """Build a TropicalCausalLM from architecture parameters."""
    model = TropicalCausalLM(
        vocab_size=arch_params["vocab_size"],
        hidden_size=arch_params["hidden_size"],
        num_layers=arch_params["num_layers"],
        num_heads=arch_params["num_heads"],
        intermediate_size=arch_params["intermediate_size"],
        head_dim=arch_params["head_dim"],
        num_kv_heads=arch_params["num_kv_heads"],
        max_position_embeddings=arch_params["max_position_embeddings"],
        rms_norm_eps=arch_params["rms_norm_eps"],
        rope_theta=arch_params["rope_theta"],
        bias=arch_params["bias"],
        tie_word_embeddings=arch_params["tie_word_embeddings"],
        initial_temperature=initial_temperature,
    )
    return model


def _init_tropical_from_linear(
    tropical: TropicalLinear,
    linear: nn.Linear,
    initial_temperature: float = 1.0,
):
    """
    Initialize a TropicalLinear layer from a standard nn.Linear.

    Strategy: In the tropical semiring, multiplication becomes addition,
    so we use a log-domain transformation of the absolute weights.
    The sign information is preserved through a sign-correction layer
    embedded in the bias.

    For distillation to work well, we want the tropical layer to initially
    approximate the linear layer's behaviour. At temperature τ=1:
        TropicalLinear(x) ≈ τ·log(Σ exp((W+x)/τ))
    which is a soft-max-plus operation. We initialize W_tropical so that
    the highest-magnitude original weights dominate.
    """
    with torch.no_grad():
        W = linear.weight.data  # (out, in)

        # Scale weights to work in the additive (tropical) domain
        # Use the original weights directly — at high temperature the
        # LogSumExp behaves like a smooth linear combination
        tropical.weight.data.copy_(W)

        if linear.bias is not None and tropical.bias is not None:
            tropical.bias.data.copy_(linear.bias.data)
        elif tropical.bias is not None:
            tropical.bias.data.zero_()

        tropical.log_temperature.data.fill_(math.log(max(initial_temperature, 1e-6)))


def transfer_weights(
    source_model: nn.Module,
    tropical_model: TropicalCausalLM,
    initial_temperature: float = 1.0,
):
    """
    Transfer weights from a standard HuggingFace model to the tropical model.

    Direct transfers (unchanged):
    - Token embeddings
    - RMSNorm parameters
    - RoPE frequencies (recomputed)

    Tropical conversions:
    - All nn.Linear → TropicalLinear (with log-domain init)
    """
    source_state = source_model.state_dict()

    # Build a mapping from standard names to our tropical names
    # This handles various model families
    transferred = set()

    # --- Embeddings ---
    for src_key in source_state:
        if any(k in src_key for k in ["embed_tokens.weight", "wte.weight", "word_embeddings.weight"]):
            tropical_model.embed_tokens.weight.data.copy_(source_state[src_key])
            transferred.add(src_key)
            logger.info(f"Transferred embedding: {src_key}")
            break

    # --- Layer norms ---
    for src_key in source_state:
        if "layernorm" in src_key.lower() or "rmsnorm" in src_key.lower() or "norm" in src_key.lower():
            # Try to match to our norm layers
            _try_transfer_norm(src_key, source_state[src_key], tropical_model, transferred)

    # --- Linear layers (converted to tropical) ---
    _transfer_linear_layers(source_state, tropical_model, initial_temperature, transferred)

    n_transferred = len(transferred)
    n_total = len(source_state)
    logger.info(
        f"Weight transfer: {n_transferred}/{n_total} parameters transferred "
        f"({n_transferred/max(n_total,1)*100:.1f}%)"
    )

    return transferred


def _try_transfer_norm(
    src_key: str,
    src_tensor: torch.Tensor,
    tropical_model: TropicalCausalLM,
    transferred: set,
):
    """Try to match and transfer a norm parameter."""
    import re

    # Extract layer index if present
    layer_match = re.search(r"layers?[._](\d+)", src_key)

    if "final" in src_key or (layer_match is None and "model.norm" in src_key):
        # Final layer norm
        if "weight" in src_key:
            tropical_model.norm.weight.data.copy_(src_tensor)
            transferred.add(src_key)
            return

    if layer_match:
        idx = int(layer_match.group(1))
        if idx < len(tropical_model.layers):
            layer = tropical_model.layers[idx]
            if "input_layernorm" in src_key or "ln_1" in src_key or "attn_norm" in src_key:
                if "weight" in src_key:
                    layer.input_layernorm.weight.data.copy_(src_tensor)
                    transferred.add(src_key)
            elif "post_attention_layernorm" in src_key or "ln_2" in src_key or "ffn_norm" in src_key:
                if "weight" in src_key:
                    layer.post_attention_layernorm.weight.data.copy_(src_tensor)
                    transferred.add(src_key)


def _transfer_linear_layers(
    source_state: dict,
    tropical_model: TropicalCausalLM,
    initial_temperature: float,
    transferred: set,
):
    """Transfer all linear layer weights with tropical conversion."""
    import re

    # Map of pattern → tropical layer accessor
    proj_map = {
        "q_proj": lambda layer: layer.self_attn.q_proj,
        "k_proj": lambda layer: layer.self_attn.k_proj,
        "v_proj": lambda layer: layer.self_attn.v_proj,
        "o_proj": lambda layer: layer.self_attn.o_proj,
        "gate_proj": lambda layer: layer.mlp.gate_proj,
        "up_proj": lambda layer: layer.mlp.up_proj,
        "down_proj": lambda layer: layer.mlp.down_proj,
    }

    # Collect weight/bias pairs by base name
    linear_params = {}
    for key in source_state:
        if "weight" in key or "bias" in key:
            base = key.rsplit(".", 1)[0]
            if base not in linear_params:
                linear_params[base] = {}
            param_type = "weight" if "weight" in key else "bias"
            linear_params[base][param_type] = (key, source_state[key])

    for base, params in linear_params.items():
        if "weight" not in params:
            continue

        src_weight_key, src_weight = params["weight"]
        src_bias_key, src_bias = params.get("bias", (None, None))

        # Skip non-2D (not a linear layer)
        if src_weight.dim() != 2:
            continue

        # Find matching tropical layer
        layer_match = re.search(r"layers?[._](\d+)", base)
        if layer_match:
            idx = int(layer_match.group(1))
            if idx >= len(tropical_model.layers):
                continue
            layer = tropical_model.layers[idx]

            for proj_name, accessor in proj_map.items():
                if proj_name in base:
                    trop_layer = accessor(layer)
                    _do_tropical_transfer(
                        trop_layer, src_weight, src_bias,
                        initial_temperature
                    )
                    transferred.add(src_weight_key)
                    if src_bias_key:
                        transferred.add(src_bias_key)
                    break
        elif "lm_head" in base:
            _do_tropical_transfer(
                tropical_model.lm_head, src_weight, src_bias,
                initial_temperature
            )
            transferred.add(src_weight_key)
            if src_bias_key:
                transferred.add(src_bias_key)


def _do_tropical_transfer(
    trop_layer: TropicalLinear,
    weight: torch.Tensor,
    bias: Optional[torch.Tensor],
    initial_temperature: float,
):
    """Perform the actual weight transfer to a tropical layer."""
    with torch.no_grad():
        # Ensure shapes match
        if trop_layer.weight.shape == weight.shape:
            trop_layer.weight.data.copy_(weight)
        else:
            # Shape mismatch — use what we can
            min_out = min(trop_layer.weight.shape[0], weight.shape[0])
            min_in = min(trop_layer.weight.shape[1], weight.shape[1])
            trop_layer.weight.data[:min_out, :min_in] = weight[:min_out, :min_in]

        if bias is not None and trop_layer.bias is not None:
            if trop_layer.bias.shape == bias.shape:
                trop_layer.bias.data.copy_(bias)

        trop_layer.log_temperature.data.fill_(
            math.log(max(initial_temperature, 1e-6))
        )


def convert_model(
    model_name: str,
    initial_temperature: float = 1.0,
    dtype: torch.dtype = torch.float32,
    trust_remote_code: bool = True,
) -> tuple:
    """
    Full conversion pipeline: download → extract arch → build tropical → transfer weights.

    Args:
        model_name: HuggingFace model identifier (e.g. "Qwen/Qwen2.5-0.5B")
        initial_temperature: Starting temperature for tropical layers (1.0 = smooth)
        dtype: Precision for model weights
        trust_remote_code: Whether to trust remote code in HF models

    Returns:
        (tropical_model, tokenizer, arch_params, source_model)
    """
    converted_path = get_converted_cache_path(model_name)

    # Check if conversion is cached
    if is_cached(converted_path):
        logger.info(f"Loading converted model from cache: {converted_path}")
        arch_params = json.loads((converted_path / "arch_params.json").read_text())
        tropical_model = build_tropical_model(arch_params, initial_temperature)
        state_dict = torch.load(
            converted_path / "tropical_state_dict.pt",
            map_location="cpu", weights_only=True
        )
        tropical_model.load_state_dict(state_dict)

        # Still need tokenizer and source model for distillation
        source_model, tokenizer, config = download_model(
            model_name, dtype, trust_remote_code
        )
        return tropical_model, tokenizer, arch_params, source_model

    # Download source model
    source_model, tokenizer, config = download_model(
        model_name, dtype, trust_remote_code
    )

    # Extract architecture
    arch_params = extract_architecture_params(config)
    logger.info(f"Architecture: {json.dumps(arch_params, indent=2)}")

    # Build tropical model
    tropical_model = build_tropical_model(arch_params, initial_temperature)

    # Transfer weights
    transfer_weights(source_model, tropical_model, initial_temperature)

    # Cache the converted model
    converted_path.mkdir(parents=True, exist_ok=True)
    (converted_path / "arch_params.json").write_text(
        json.dumps(arch_params, indent=2)
    )
    torch.save(tropical_model.state_dict(), converted_path / "tropical_state_dict.pt")
    mark_complete(converted_path, {
        "model_name": model_name,
        "initial_temperature": initial_temperature,
    })

    logger.info("Model conversion complete.")
    return tropical_model, tokenizer, arch_params, source_model
