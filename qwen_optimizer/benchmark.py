"""Benchmarking suite for measuring model performance."""

import time
from dataclasses import dataclass
from typing import List, Optional

import torch
from transformers import AutoModelForCausalLM, AutoTokenizer


@dataclass
class BenchmarkResult:
    """Results from a single benchmark run."""

    stage: str
    quantization: str
    vram_mb: float
    tokens_per_sec_prefill: float
    tokens_per_sec_decode: float
    perplexity: Optional[float]
    latency_ttft_ms: float
    latency_tpot_ms: float
    load_time_s: float
    notes: str = ""


class BenchmarkSuite:
    """Run standardized benchmarks across optimization stages."""

    def __init__(self, tokenizer, device: str = "cuda"):
        self.tokenizer = tokenizer
        self.device = device
        self.prompt = "Explain the Pythagorean theorem in one sentence:"
        self.gen_tokens = 50

    def _get_vram_mb(self) -> float:
        if torch.cuda.is_available():
            return torch.cuda.memory_allocated() / (1024 ** 2)
        return 0.0

    def _warmup(self, model, inputs):
        with torch.no_grad():
            _ = model.generate(**inputs, max_new_tokens=10, do_sample=False)
        torch.cuda.synchronize()

    def run_inference_benchmark(
        self,
        model,
        stage_name: str,
        quantization_label: str,
        load_time: float = 0.0,
        notes: str = "",
    ) -> BenchmarkResult:
        """Measure prefill and decode throughput for a loaded model."""
        inputs = self.tokenizer(self.prompt, return_tensors="pt").to(model.device)

        self._warmup(model, inputs)

        # Prefill (TTFT)
        t0 = time.time()
        with torch.no_grad():
            _ = model.generate(**inputs, max_new_tokens=1, do_sample=False)
        ttft = (time.time() - t0) * 1000

        # Decode
        t0 = time.time()
        with torch.no_grad():
            _ = model.generate(
                **inputs,
                max_new_tokens=self.gen_tokens,
                do_sample=False,
                use_cache=True,
            )
        total_t = time.time() - t0

        prefill_tok_s = inputs.input_ids.shape[1] / (ttft / 1000)
        decode_tok_s = self.gen_tokens / total_t

        return BenchmarkResult(
            stage=stage_name,
            quantization=quantization_label,
            vram_mb=self._get_vram_mb(),
            tokens_per_sec_prefill=prefill_tok_s,
            tokens_per_sec_decode=decode_tok_s,
            perplexity=None,
            latency_ttft_ms=ttft,
            latency_tpot_ms=(total_t * 1000) / self.gen_tokens,
            load_time_s=load_time,
            notes=notes,
        )

    def run_perplexity(
        self,
        model,
        text: str,
        max_length: Optional[int] = None,
        stride: int = 512,
    ) -> float:
        """Evaluate perplexity on a text string using sliding-window cross-entropy."""
        if max_length is None:
            max_length = getattr(
                model.config, "max_position_embeddings", 2048
            )

        encodings = self.tokenizer(text, return_tensors="pt")
        seq_len = encodings.input_ids.size(1)
        nlls = []
        prev_end_loc = 0

        for begin_loc in range(0, seq_len, stride):
            end_loc = min(begin_loc + max_length, seq_len)
            trg_len = end_loc - prev_end_loc
            input_ids = encodings.input_ids[:, begin_loc:end_loc].to(model.device)
            target_ids = input_ids.clone()
            target_ids[:, :-trg_len] = -100

            with torch.no_grad():
                outputs = model(input_ids, labels=target_ids)
                nlls.append(outputs.loss * trg_len)

            prev_end_loc = end_loc
            if end_loc == seq_len:
                break

        ppl = torch.exp(torch.stack(nlls).sum() / end_loc)
        return ppl.item()
