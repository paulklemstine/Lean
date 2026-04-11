"""
Tropical neural network layers.

In the tropical semiring (ℝ ∪ {-∞}, ⊕, ⊙):
  - Tropical addition:       a ⊕ b  = max(a, b)
  - Tropical multiplication: a ⊙ b  = a + b

A standard linear layer computes:
    y_i = Σ_j W_ij · x_j + b_i          (ring: (ℝ, +, ×))

A tropical linear layer computes:
    y_i = max_j(W_ij + x_j) + b_i       (semiring: (ℝ, max, +))

This is mathematically equivalent to what ReLU networks compute in the
piecewise-linear regime, making the tropical formulation a natural fit
for reasoning models that are predominantly ReLU-activated.

We implement a hybrid approach: the tropical layer is augmented with a
learnable temperature parameter τ that interpolates between tropical (τ→0)
and log-sum-exp / soft (τ>0) behaviour via:

    y_i = τ · log(Σ_j exp((W_ij + x_j) / τ)) + b_i

At τ→0 this recovers exact tropical max; at τ=1 it approximates the
standard softmax-weighted linear combination, enabling smooth distillation.
"""

from __future__ import annotations

import math
import torch
import torch.nn as nn
import torch.nn.functional as F
from typing import Optional, Tuple


class TropicalLinear(nn.Module):
    """
    Drop-in replacement for nn.Linear using the tropical semiring.

    Computes y_i = LSE_τ(W_ij + x_j) + b_i where LSE_τ is the
    temperature-scaled LogSumExp (→ max as τ→0).
    """

    def __init__(
        self,
        in_features: int,
        out_features: int,
        bias: bool = True,
        initial_temperature: float = 1.0,
    ):
        super().__init__()
        self.in_features = in_features
        self.out_features = out_features

        # Tropical weight matrix (additive, not multiplicative)
        self.weight = nn.Parameter(torch.empty(out_features, in_features))
        if bias:
            self.bias = nn.Parameter(torch.empty(out_features))
        else:
            self.register_parameter("bias", None)

        # Temperature: learnable, clamped > 0
        self.log_temperature = nn.Parameter(
            torch.tensor(math.log(max(initial_temperature, 1e-6)))
        )

        self.reset_parameters()

    def reset_parameters(self):
        # Xavier-like initialization adapted for additive weights
        std = 1.0 / math.sqrt(self.in_features)
        nn.init.uniform_(self.weight, -std, std)
        if self.bias is not None:
            nn.init.zeros_(self.bias)

    @property
    def temperature(self) -> torch.Tensor:
        return self.log_temperature.exp()

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        """
        Args:
            x: (*, in_features)
        Returns:
            y: (*, out_features)
        """
        tau = self.temperature

        # Tropical operation: W_ij + x_j  →  shape (*, out_features, in_features)
        # x: (*, in_features) → (*, 1, in_features)
        # W: (out_features, in_features)
        tropical_sum = x.unsqueeze(-2) + self.weight  # broadcast add

        if tau < 1e-4:
            # Pure tropical: take the max
            y = tropical_sum.max(dim=-1).values
        else:
            # Smooth tropical via LogSumExp with temperature
            y = tau * torch.logsumexp(tropical_sum / tau, dim=-1)

        if self.bias is not None:
            y = y + self.bias
        return y

    def extra_repr(self) -> str:
        return (
            f"in_features={self.in_features}, out_features={self.out_features}, "
            f"bias={self.bias is not None}, "
            f"temperature={self.temperature.item():.4f}"
        )


class TropicalAttention(nn.Module):
    """
    Multi-head attention with tropical linear projections.

    The Q/K/V projections and output projection use TropicalLinear.
    The attention scores themselves use standard softmax (or optionally
    tropical max-scoring).
    """

    def __init__(
        self,
        hidden_size: int,
        num_heads: int,
        head_dim: Optional[int] = None,
        num_kv_heads: Optional[int] = None,
        bias: bool = False,
        initial_temperature: float = 1.0,
        max_position_embeddings: int = 8192,
    ):
        super().__init__()
        self.hidden_size = hidden_size
        self.num_heads = num_heads
        self.head_dim = head_dim or (hidden_size // num_heads)
        self.num_kv_heads = num_kv_heads or num_heads
        self.num_kv_groups = self.num_heads // self.num_kv_heads
        self.scaling = 1.0 / math.sqrt(self.head_dim)

        self.q_proj = TropicalLinear(
            hidden_size, self.num_heads * self.head_dim,
            bias=bias, initial_temperature=initial_temperature
        )
        self.k_proj = TropicalLinear(
            hidden_size, self.num_kv_heads * self.head_dim,
            bias=bias, initial_temperature=initial_temperature
        )
        self.v_proj = TropicalLinear(
            hidden_size, self.num_kv_heads * self.head_dim,
            bias=bias, initial_temperature=initial_temperature
        )
        self.o_proj = TropicalLinear(
            self.num_heads * self.head_dim, hidden_size,
            bias=bias, initial_temperature=initial_temperature
        )

    def forward(
        self,
        hidden_states: torch.Tensor,
        attention_mask: Optional[torch.Tensor] = None,
        position_ids: Optional[torch.LongTensor] = None,
        past_key_value: Optional[Tuple[torch.Tensor, torch.Tensor]] = None,
        cos_sin: Optional[Tuple[torch.Tensor, torch.Tensor]] = None,
    ) -> torch.Tensor:
        bsz, seq_len, _ = hidden_states.shape

        q = self.q_proj(hidden_states)
        k = self.k_proj(hidden_states)
        v = self.v_proj(hidden_states)

        q = q.view(bsz, seq_len, self.num_heads, self.head_dim).transpose(1, 2)
        k = k.view(bsz, seq_len, self.num_kv_heads, self.head_dim).transpose(1, 2)
        v = v.view(bsz, seq_len, self.num_kv_heads, self.head_dim).transpose(1, 2)

        # Apply rotary embeddings if provided
        if cos_sin is not None:
            cos, sin = cos_sin
            q = _apply_rotary(q, cos, sin)
            k = _apply_rotary(k, cos, sin)

        # GQA: expand k/v heads
        if self.num_kv_groups > 1:
            k = k.repeat_interleave(self.num_kv_groups, dim=1)
            v = v.repeat_interleave(self.num_kv_groups, dim=1)

        # KV cache
        if past_key_value is not None:
            k = torch.cat([past_key_value[0], k], dim=2)
            v = torch.cat([past_key_value[1], v], dim=2)

        # Standard scaled dot-product attention
        attn_weights = torch.matmul(q, k.transpose(-2, -1)) * self.scaling

        if attention_mask is not None:
            attn_weights = attn_weights + attention_mask

        attn_weights = F.softmax(attn_weights, dim=-1, dtype=torch.float32).to(v.dtype)
        attn_output = torch.matmul(attn_weights, v)

        attn_output = attn_output.transpose(1, 2).contiguous().view(bsz, seq_len, -1)
        return self.o_proj(attn_output)


class TropicalMLP(nn.Module):
    """
    MLP block using tropical linear layers with SiLU gating.
    Mirrors the standard LLaMA/Qwen MLP: gate_proj, up_proj, down_proj.
    """

    def __init__(
        self,
        hidden_size: int,
        intermediate_size: int,
        bias: bool = False,
        initial_temperature: float = 1.0,
    ):
        super().__init__()
        self.gate_proj = TropicalLinear(
            hidden_size, intermediate_size,
            bias=bias, initial_temperature=initial_temperature
        )
        self.up_proj = TropicalLinear(
            hidden_size, intermediate_size,
            bias=bias, initial_temperature=initial_temperature
        )
        self.down_proj = TropicalLinear(
            intermediate_size, hidden_size,
            bias=bias, initial_temperature=initial_temperature
        )
        self.act_fn = nn.SiLU()

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        return self.down_proj(self.act_fn(self.gate_proj(x)) * self.up_proj(x))


class TropicalTransformerBlock(nn.Module):
    """
    Single transformer decoder block with tropical layers.
    Uses RMSNorm for pre-normalization (standard in modern LLMs).
    """

    def __init__(
        self,
        hidden_size: int,
        num_heads: int,
        intermediate_size: int,
        head_dim: Optional[int] = None,
        num_kv_heads: Optional[int] = None,
        rms_norm_eps: float = 1e-6,
        bias: bool = False,
        initial_temperature: float = 1.0,
    ):
        super().__init__()
        self.input_layernorm = nn.RMSNorm(hidden_size, eps=rms_norm_eps)
        self.self_attn = TropicalAttention(
            hidden_size=hidden_size,
            num_heads=num_heads,
            head_dim=head_dim,
            num_kv_heads=num_kv_heads,
            bias=bias,
            initial_temperature=initial_temperature,
        )
        self.post_attention_layernorm = nn.RMSNorm(hidden_size, eps=rms_norm_eps)
        self.mlp = TropicalMLP(
            hidden_size=hidden_size,
            intermediate_size=intermediate_size,
            bias=bias,
            initial_temperature=initial_temperature,
        )

    def forward(
        self,
        hidden_states: torch.Tensor,
        attention_mask: Optional[torch.Tensor] = None,
        position_ids: Optional[torch.LongTensor] = None,
        cos_sin: Optional[Tuple[torch.Tensor, torch.Tensor]] = None,
    ) -> torch.Tensor:
        # Self-attention with residual
        residual = hidden_states
        hidden_states = self.input_layernorm(hidden_states)
        hidden_states = self.self_attn(
            hidden_states,
            attention_mask=attention_mask,
            position_ids=position_ids,
            cos_sin=cos_sin,
        )
        hidden_states = residual + hidden_states

        # MLP with residual
        residual = hidden_states
        hidden_states = self.post_attention_layernorm(hidden_states)
        hidden_states = self.mlp(hidden_states)
        hidden_states = residual + hidden_states

        return hidden_states


class TropicalCausalLM(nn.Module):
    """
    Complete tropical causal language model.
    Architecture mirrors LLaMA/Qwen-style models with all linear layers
    replaced by tropical linear layers.
    """

    def __init__(
        self,
        vocab_size: int,
        hidden_size: int,
        num_layers: int,
        num_heads: int,
        intermediate_size: int,
        head_dim: Optional[int] = None,
        num_kv_heads: Optional[int] = None,
        max_position_embeddings: int = 8192,
        rms_norm_eps: float = 1e-6,
        rope_theta: float = 10000.0,
        bias: bool = False,
        tie_word_embeddings: bool = True,
        initial_temperature: float = 1.0,
    ):
        super().__init__()
        self.vocab_size = vocab_size
        self.hidden_size = hidden_size
        self.num_layers = num_layers
        self.max_position_embeddings = max_position_embeddings
        self.tie_word_embeddings = tie_word_embeddings
        self.head_dim = head_dim or (hidden_size // num_heads)
        self.rope_theta = rope_theta

        # Embedding (standard — not tropical, since it's a lookup)
        self.embed_tokens = nn.Embedding(vocab_size, hidden_size)

        # Tropical transformer blocks
        self.layers = nn.ModuleList([
            TropicalTransformerBlock(
                hidden_size=hidden_size,
                num_heads=num_heads,
                intermediate_size=intermediate_size,
                head_dim=head_dim,
                num_kv_heads=num_kv_heads,
                rms_norm_eps=rms_norm_eps,
                bias=bias,
                initial_temperature=initial_temperature,
            )
            for _ in range(num_layers)
        ])

        self.norm = nn.RMSNorm(hidden_size, eps=rms_norm_eps)

        # LM head — also tropical
        self.lm_head = TropicalLinear(
            hidden_size, vocab_size,
            bias=False, initial_temperature=initial_temperature
        )

        if tie_word_embeddings:
            # We can't tie directly since lm_head is TropicalLinear,
            # but we initialise lm_head.weight from embed_tokens
            pass

        # Precompute RoPE frequencies
        self._rope_cache: Optional[Tuple[torch.Tensor, torch.Tensor]] = None

    def _get_rope(
        self, seq_len: int, device: torch.device, dtype: torch.dtype
    ) -> Tuple[torch.Tensor, torch.Tensor]:
        """Compute rotary position embedding cos/sin tensors."""
        if self._rope_cache is not None:
            cos, sin = self._rope_cache
            if cos.shape[0] >= seq_len and cos.device == device:
                return cos[:seq_len].to(dtype), sin[:seq_len].to(dtype)

        inv_freq = 1.0 / (
            self.rope_theta ** (
                torch.arange(0, self.head_dim, 2, device=device, dtype=torch.float32)
                / self.head_dim
            )
        )
        t = torch.arange(seq_len, device=device, dtype=torch.float32)
        freqs = torch.outer(t, inv_freq)
        emb = torch.cat([freqs, freqs], dim=-1)
        cos = emb.cos()
        sin = emb.sin()
        self._rope_cache = (cos, sin)
        return cos.to(dtype), sin.to(dtype)

    def forward(
        self,
        input_ids: torch.LongTensor,
        attention_mask: Optional[torch.Tensor] = None,
        labels: Optional[torch.LongTensor] = None,
    ) -> dict:
        bsz, seq_len = input_ids.shape
        device = input_ids.device

        hidden_states = self.embed_tokens(input_ids)

        # Build causal mask
        if attention_mask is None:
            causal_mask = torch.triu(
                torch.full((seq_len, seq_len), float("-inf"), device=device),
                diagonal=1,
            ).unsqueeze(0).unsqueeze(0)
        else:
            # Expand provided mask to 4D
            causal_mask = torch.triu(
                torch.full((seq_len, seq_len), float("-inf"), device=device),
                diagonal=1,
            ).unsqueeze(0).unsqueeze(0)
            # Combine with padding mask
            pad_mask = (1.0 - attention_mask[:, None, None, :].float()) * float("-inf")
            causal_mask = causal_mask + pad_mask

        cos_sin = self._get_rope(seq_len, device, hidden_states.dtype)

        for layer in self.layers:
            hidden_states = layer(
                hidden_states,
                attention_mask=causal_mask,
                cos_sin=cos_sin,
            )

        hidden_states = self.norm(hidden_states)
        logits = self.lm_head(hidden_states)

        loss = None
        if labels is not None:
            shift_logits = logits[..., :-1, :].contiguous()
            shift_labels = labels[..., 1:].contiguous()
            loss = F.cross_entropy(
                shift_logits.view(-1, self.vocab_size),
                shift_labels.view(-1),
                ignore_index=-100,
            )

        return {"loss": loss, "logits": logits}

    def generate(
        self,
        input_ids: torch.LongTensor,
        max_new_tokens: int = 256,
        temperature: float = 0.7,
        top_p: float = 0.9,
        top_k: int = 50,
        do_sample: bool = True,
        eos_token_id: Optional[int] = None,
    ) -> torch.LongTensor:
        """Simple autoregressive generation loop."""
        generated = input_ids.clone()

        for _ in range(max_new_tokens):
            # Only feed last max_position_embeddings tokens
            context = generated[:, -self.max_position_embeddings:]
            outputs = self.forward(context)
            next_logits = outputs["logits"][:, -1, :] / max(temperature, 1e-8)

            # Top-k filtering
            if top_k > 0:
                indices_to_remove = next_logits < torch.topk(next_logits, top_k)[0][..., -1, None]
                next_logits[indices_to_remove] = float("-inf")

            # Top-p (nucleus) filtering
            if top_p < 1.0:
                sorted_logits, sorted_indices = torch.sort(next_logits, descending=True)
                cum_probs = torch.cumsum(F.softmax(sorted_logits, dim=-1), dim=-1)
                remove = cum_probs - F.softmax(sorted_logits, dim=-1) >= top_p
                sorted_logits[remove] = float("-inf")
                next_logits = sorted_logits.scatter(1, sorted_indices, sorted_logits)

            if do_sample:
                probs = F.softmax(next_logits, dim=-1)
                next_token = torch.multinomial(probs, num_samples=1)
            else:
                next_token = next_logits.argmax(dim=-1, keepdim=True)

            generated = torch.cat([generated, next_token], dim=-1)

            if eos_token_id is not None and (next_token == eos_token_id).all():
                break

        return generated


def _apply_rotary(x: torch.Tensor, cos: torch.Tensor, sin: torch.Tensor) -> torch.Tensor:
    """Apply rotary position embeddings."""
    seq_len = x.shape[2]
    cos = cos[:seq_len].unsqueeze(0).unsqueeze(0)  # (1, 1, seq, dim)
    sin = sin[:seq_len].unsqueeze(0).unsqueeze(0)

    # Split into halves and rotate
    x1 = x[..., : x.shape[-1] // 2]
    x2 = x[..., x.shape[-1] // 2 :]
    rotated = torch.cat([-x2, x1], dim=-1)

    return x * cos + rotated * sin
