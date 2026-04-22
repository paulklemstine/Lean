"""Quantization utilities: NF4 (bitsandbytes) and GGUF conversion."""

import os
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import List, Optional

import torch
from transformers import (
    AutoModelForCausalLM,
    BitsAndBytesConfig,
)


@dataclass
class QuantizationConfig:
    """Configuration for a quantization pass."""

    bits: int = 4
    quant_type: str = "nf4"  # nf4 or fp4
    use_double_quant: bool = True
    compute_dtype: torch.dtype = torch.bfloat16
    gguf_levels: Optional[List[str]] = None

    def __post_init__(self):
        if self.gguf_levels is None:
            self.gguf_levels = ["Q4_K_M", "Q3_K_M"]


def quantize_nf4(
    model_path: str,
    device_map: str = "auto",
    trust_remote_code: bool = True,
    config: Optional[QuantizationConfig] = None,
):
    """Load a model with 4-bit NF4 quantization via bitsandbytes.

    Returns the quantized model and the config used.
    """
    if config is None:
        config = QuantizationConfig()

    bnb_config = BitsAndBytesConfig(
        load_in_4bit=True,
        bnb_4bit_quant_type=config.quant_type,
        bnb_4bit_use_double_quant=config.use_double_quant,
        bnb_4bit_compute_dtype=config.compute_dtype,
    )

    model = AutoModelForCausalLM.from_pretrained(
        model_path,
        quantization_config=bnb_config,
        device_map=device_map,
        trust_remote_code=trust_remote_code,
    )
    return model, config


def quantize_gguf(
    model_path: str,
    output_dir: str,
    llama_cpp_dir: str,
    quant_levels: Optional[List[str]] = None,
) -> dict:
    """Convert a HuggingFace model to GGUF and quantize at multiple levels.

    Requires llama.cpp to be cloned at ``llama_cpp_dir``.
    Returns a dict mapping quant level names to file paths.
    """
    if quant_levels is None:
        quant_levels = ["Q4_K_M", "Q3_K_M"]

    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    base_name = Path(model_path).name
    f16_path = output_dir / f"{base_name}_f16.gguf"

    # Convert HF to GGUF (F16)
    if not f16_path.exists():
        subprocess.run(
            [
                "python3",
                os.path.join(llama_cpp_dir, "convert_hf_to_gguf.py"),
                model_path,
                "--outfile",
                str(f16_path),
                "--outtype",
                "f16",
            ],
            check=True,
        )

    results = {"f16": str(f16_path)}

    # Quantize to each level
    for level in quant_levels:
        out_path = output_dir / f"{base_name}_{level}.gguf"
        if not out_path.exists():
            quantize_bin = os.path.join(llama_cpp_dir, "llama-quantize")
            if not os.path.exists(quantize_bin):
                # Build llama.cpp
                subprocess.run(
                    ["make", "-C", llama_cpp_dir, "-j"],
                    check=True,
                )
            subprocess.run(
                [quantize_bin, str(f16_path), str(out_path), level],
                check=True,
            )
        results[level] = str(out_path)

    return results
