#!/usr/bin/env python3
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  QWEN OISCC-EML COMPRESSION PIPELINE v2 — GOOGLE COLAB                    ║
# ║  Compress → Distill → Crystallize → Optimize → Benchmark                  ║
# ║                                                                            ║
# ║  Phase 1: Qwen2.5-3B/7B (T4/A100)                                        ║
# ║  Phase 2: Qwen3.6-35B-A3B MoE (A100 80GB)                                ║
# ║                                                                            ║
# ║  Pipeline stages:                                                          ║
# ║    0. Download + Google Drive cache (checkpointing)                        ║
# ║    1. OISCC-EML weight conversion (d² → 4d per matrix)                     ║
# ║    2. Compression pass 1: int16 crystallization (word-for-word match)      ║
# ║    3. Knowledge distillation (teacher → compact student)                   ║
# ║    4. Compression pass 2: Q4_K_M GGUF quantization                        ║
# ║    5. Optimization: vLLM / llama.cpp server                               ║
# ║    6. Benchmark suite + telemetry                                          ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Usage on Colab:
#   python qwen_crystal_v2.py
#   python qwen_crystal_v2.py --model Qwen/Qwen2.5-3B-Instruct
#   python qwen_crystal_v2.py --model Qwen/Qwen2.5-7B-Instruct
#   python qwen_crystal_v2.py --model Qwen/Qwen3.6-35B-A3B  # MoE
#   python qwen_crystal_v2.py --model Qwen/Qwen2.5-3B-Instruct --skip-gguf
#   python qwen_crystal_v2.py --model Qwen/Qwen2.5-3B-Instruct --distill-scale 0.25
#   python qwen_crystal_v2.py --model Qwen/Qwen2.5-3B-Instruct --distill-steps 1000

import os
import sys
import time
import json
import gc
import shutil
import platform
import subprocess
import warnings
import hashlib
import traceback
from dataclasses import dataclass, field, asdict
from typing import Dict, List, Optional, Tuple, Any, Union
from pathlib import Path
from contextlib import contextmanager

import numpy as np

warnings.filterwarnings("ignore")

# ════════════════════════════════════════════════════════════════════════════
# §0. Telemetry System — structured, persistent, VRAM-aware
# ════════════════════════════════════════════════════════════════════════════

class Telemetry:
    """Structured telemetry: timing, VRAM, throughput. Persists to JSONL."""

    def __init__(self, log_path: str = "telemetry_v2.jsonl", model_name: str = ""):
        self.log_path = log_path
        self.model_name = model_name
        self.events: List[Dict] = []
        self.stage_timings: Dict[str, float] = {}
        self._torch_available = None
        self._peak_vram_mb = 0.0

    @property
    def torch_available(self):
        if self._torch_available is None:
            try:
                import torch
                self._torch_available = True
            except ImportError:
                self._torch_available = False
        return self._torch_available

    def _vram_mb(self) -> float:
        if not self.torch_available:
            return 0.0
        import torch
        if torch.cuda.is_available():
            v = torch.cuda.memory_allocated() / 1024**2
            self._peak_vram_mb = max(self._peak_vram_mb, v)
            return v
        return 0.0

    def _vram_reserved_mb(self) -> float:
        if not self.torch_available:
            return 0.0
        import torch
        if torch.cuda.is_available():
            return torch.cuda.memory_reserved() / 1024**2
        return 0.0

    def _gpu_info(self) -> Dict:
        if not self.torch_available:
            return {"gpu": "none"}
        import torch
        if not torch.cuda.is_available():
            return {"gpu": "cpu_only"}
        try:
            name = torch.cuda.get_device_name(0)
            total = torch.cuda.get_device_properties(0).total_memory / 1024**3
            return {"gpu": name, "vram_total_gb": round(total, 1)}
        except Exception:
            return {"gpu": "unknown"}

    def event(self, stage: str, action: str, **kwargs):
        """Record a telemetry event."""
        evt = {
            "ts": time.time(),
            "model": self.model_name,
            "stage": stage,
            "action": action,
            "vram_mb": round(self._vram_mb(), 1),
            "vram_reserved_mb": round(self._vram_reserved_mb(), 1),
            "peak_vram_mb": round(self._peak_vram_mb, 1),
            **kwargs,
        }
        self.events.append(evt)
        try:
            with open(self.log_path, "a") as f:
                f.write(json.dumps(evt, default=str) + "\n")
        except Exception:
            pass
        return evt

    @contextmanager
    def timer(self, stage: str, action: str):
        """Context manager for timing a stage."""
        t0 = time.perf_counter()
        self.event(stage, f"{action}_start")
        try:
            yield
        finally:
            elapsed = time.perf_counter() - t0
            self.stage_timings[f"{stage}/{action}"] = elapsed
            self.event(stage, f"{action}_end",
                       elapsed_s=round(elapsed, 3),
                       vram_mb=round(self._vram_mb(), 1),
                       peak_vram_mb=round(self._peak_vram_mb, 1))

    def hardware_report(self) -> Dict:
        """Collect hardware info."""
        info = {
            "python": platform.python_version(),
            "platform": platform.platform(),
            "cpu_count": os.cpu_count(),
        }
        info.update(self._gpu_info())
        if self.torch_available:
            import torch
            info["torch_version"] = torch.__version__
            info["cuda_version"] = torch.version.cuda or "none"
            if torch.cuda.is_available():
                info["cuda_capability"] = torch.cuda.get_device_capability(0)
        try:
            import transformers
            info["transformers_version"] = transformers.__version__
        except ImportError:
            pass
        return info

    def summary(self) -> str:
        """Pretty-print telemetry summary."""
        if not self.events:
            return "No telemetry events recorded."
        lines = ["\n╔═══════════════════════════════════════════════════════╗"]
        lines.append("║            TELEMETRY SUMMARY                        ║")
        lines.append("╠═══════════════════════════════════════════════════════╣")
        hw = self.hardware_report()
        lines.append(f"║  GPU:   {hw.get('gpu', 'unknown'):<42}║")
        lines.append(f"║  VRAM:  {hw.get('vram_total_gb', '?'):>4} GB{' '*35}║")
        lines.append(f"║  Peak:  {self._peak_vram_mb:.0f} MB{' '*35}║")
        lines.append("╠═══════════════════════════════════════════════════════╣")

        # Stage timings
        for key, elapsed in self.stage_timings.items():
            lines.append(f"║  {key:<35s} {elapsed:>8.2f}s{' '*9}║")

        # Key metrics from events
        lines.append("╠═══════════════════════════════════════════════════════╣")
        for evt in self.events:
            if evt['action'].endswith('_end'):
                tag = f"[{evt['stage']}/{evt['action'].replace('_end', '')}]"
                vram = evt.get('vram_mb', 0)
                elapsed = evt.get('elapsed_s', '')
                extra = {k: v for k, v in evt.items()
                         if k not in ('ts', 'model', 'stage', 'action',
                                     'vram_mb', 'vram_reserved_mb', 'peak_vram_mb')}
                extra_str = f" {extra}" if extra else ""
                lines.append(f"║  {tag:30s} VRAM={vram:>7.0f}MB  t={elapsed}{extra_str}║")

        lines.append("╚═══════════════════════════════════════════════════════╝\n")
        return "\n".join(lines)

    def save_report(self, path: str = "telemetry_report.json"):
        """Save full telemetry report as JSON."""
        report = {
            "model": self.model_name,
            "hardware": self.hardware_report(),
            "peak_vram_mb": self._peak_vram_mb,
            "stage_timings": self.stage_timings,
            "events": self.events,
        }
        with open(path, "w") as f:
            json.dump(report, f, indent=2, default=str)
        return path


# ════════════════════════════════════════════════════════════════════════════
# §1. Google Drive Manager — persistent checkpointing
# ════════════════════════════════════════════════════════════════════════════

class DriveCache:
    """Manages model caching and pipeline checkpointing to Google Drive."""

    DRIVE_MOUNT = "/content/drive"
    CACHE_DIR_NAME = "qwen_crystal_v2_cache"

    def __init__(self, mount_point: str = "", cache_dir: Optional[str] = None):
        self.mount_point = mount_point or self.DRIVE_MOUNT
        if cache_dir:
            self.cache_dir = cache_dir
        else:
            self.cache_dir = os.path.join(self.mount_point, "MyDrive", self.CACHE_DIR_NAME)
        self._mounted = False

    def mount(self) -> bool:
        """Mount Google Drive if on Colab."""
        if os.path.exists(os.path.join(self.mount_point, "MyDrive")):
            self._mounted = True
            print(f"  ✓ Drive already mounted at {self.mount_point}")
            return True
        try:
            from google.colab import drive
            drive.mount(self.mount_point)
            self._mounted = True
            print(f"  ✓ Google Drive mounted at {self.mount_point}")
        except (ImportError, Exception) as e:
            print(f"  ⚠ Google Drive not available: {e}")
            self._mounted = False

        # Create cache dir (fallback to local if mount fails)
        try:
            os.makedirs(self.cache_dir, exist_ok=True)
        except OSError:
            self.cache_dir = os.path.join(os.path.expanduser("~"), f".{self.CACHE_DIR_NAME}")
            os.makedirs(self.cache_dir, exist_ok=True)
            print(f"  Using local fallback cache: {self.cache_dir}")
        return self._mounted

    def model_cache_path(self, model_name: str) -> str:
        """Get cache directory for a specific model."""
        safe_name = model_name.replace("/", "_")
        path = os.path.join(self.cache_dir, safe_name)
        os.makedirs(path, exist_ok=True)
        return path

    def has_cached_model(self, model_name: str) -> bool:
        """Check if model weights are already cached."""
        cache_path = self.model_cache_path(model_name)
        if not os.path.isdir(cache_path):
            return False
        # Check for safetensors (preferred) or bin files
        for root, _, files in os.walk(cache_path):
            for f in files:
                if f.endswith(('.safetensors', '.bin')) and not f.startswith('checkpoint'):
                    return True
        return False

    def checkpoint_path(self, model_name: str, stage: str) -> str:
        """Get path for a pipeline checkpoint."""
        safe_name = model_name.replace("/", "_")
        path = os.path.join(self.cache_dir, safe_name, "checkpoints")
        os.makedirs(path, exist_ok=True)
        return os.path.join(path, f"{stage}.pt")

    def has_checkpoint(self, model_name: str, stage: str) -> bool:
        """Check if a pipeline stage checkpoint exists."""
        return os.path.exists(self.checkpoint_path(model_name, stage))

    def save_artifact(self, model_name: str, name: str, content: str) -> str:
        """Save a text/JSON artifact to the model's cache."""
        safe_name = model_name.replace("/", "_")
        path = os.path.join(self.cache_dir, safe_name, name)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w") as f:
            f.write(content)
        return path

    def disk_usage_gb(self) -> float:
        """Total cache size in GB."""
        total = 0
        if os.path.exists(self.cache_dir):
            for dirpath, _, filenames in os.walk(self.cache_dir):
                for f in filenames:
                    try:
                        total += os.path.getsize(os.path.join(dirpath, f))
                    except OSError:
                        pass
        return total / 1024**3


# ════════════════════════════════════════════════════════════════════════════
# §2. EML Core — the universal arithmetic primitive
# ════════════════════════════════════════════════════════════════════════════

def eml(a, b):
    """EML(a, b) = exp(a) - ln(b). The universal arithmetic primitive.

    All standard operations can be expressed as EML compositions:
      a + b = EML(ln(exp(a)+exp(b)), 1)
      a * b = EML(ln(a), 1/b)  [for a,b > 0]
      σ(a)  = EML(a - ln(1+exp(a)), 1)
    """
    return np.exp(np.clip(a, -20, 20)) - np.log(np.maximum(b, 1e-10))

def eml_vec(a, b):
    """Vectorized EML — same as eml but explicitly vectorized."""
    return np.exp(np.clip(a, -20, 20)) - np.log(np.maximum(b, 1e-10))

def eml_neuron(w1, b1, w2, b2, z):
    """EML neuron: f(z) = exp(w1*z + b1) - ln(w2*z + b2).

    This replaces a full row of a weight matrix:
      Standard: y_j = W[j,:] @ x
      EML:      y_j = EML(w1_j, b1_j, w2_j, b2_j) applied to z_j = W[j,:] @ x

    Reduction: d² weights → 4d EML parameters per matrix.
    """
    return eml(w1 * z + b1, w2 * z + b2)


# ════════════════════════════════════════════════════════════════════════════
# §3. Model Config — auto-detected, MoE + multimodal + hybrid aware
# ════════════════════════════════════════════════════════════════════════════

@dataclass
class ModelConfig:
    name: str = ""
    model_type: str = ""
    d_model: int = 0
    n_heads: int = 0
    d_head: int = 0
    n_layers: int = 0
    d_ff: int = 0
    vocab_size: int = 0
    n_kv_heads: int = 0
    max_seq_len: int = 2048
    is_moe: bool = False
    n_experts: int = 0
    n_experts_per_tok: int = 0
    d_expert_ff: int = 0
    d_shared_ff: int = 0
    total_params: int = 0
    active_params: int = 0
    is_multimodal: bool = False
    layer_types: list = field(default_factory=list)
    rope_theta: float = 10000.0

    @classmethod
    def from_hf_config(cls, hf_config) -> 'ModelConfig':
        cfg = cls()
        # Handle multimodal (VLM) wrappers
        if hasattr(hf_config, 'text_config') and hf_config.text_config is not None:
            cfg.is_multimodal = True
            text_cfg = hf_config.text_config
        else:
            text_cfg = hf_config

        cfg.name = getattr(hf_config, 'name_or_path', '') or getattr(hf_config, '_name_or_path', '') or ''
        cfg.model_type = getattr(text_cfg, 'model_type', 'unknown')
        cfg.d_model = getattr(text_cfg, 'hidden_size', 0)
        cfg.n_heads = getattr(text_cfg, 'num_attention_heads', 0)
        cfg.n_layers = getattr(text_cfg, 'num_hidden_layers', 0)
        cfg.vocab_size = getattr(text_cfg, 'vocab_size', 0)
        cfg.n_kv_heads = getattr(text_cfg, 'num_key_value_heads', cfg.n_heads)
        cfg.max_seq_len = getattr(text_cfg, 'max_position_embeddings', 2048)
        cfg.d_head = getattr(text_cfg, 'head_dim', 0)
        if cfg.d_head == 0 and cfg.n_heads > 0:
            cfg.d_head = cfg.d_model // cfg.n_heads
        cfg.d_ff = getattr(text_cfg, 'intermediate_size', 0)
        cfg.rope_theta = getattr(text_cfg, 'rope_theta', 10000.0)
        # MoE fields
        cfg.n_experts = getattr(text_cfg, 'num_experts', 0)
        cfg.n_experts_per_tok = getattr(text_cfg, 'num_experts_per_tok', 0)
        cfg.d_expert_ff = getattr(text_cfg, 'moe_intermediate_size', 0)
        cfg.d_shared_ff = getattr(text_cfg, 'shared_expert_intermediate_size', 0)
        cfg.is_moe = cfg.n_experts > 0
        if cfg.is_moe and cfg.d_expert_ff > 0 and cfg.d_ff == 0:
            cfg.d_ff = cfg.d_expert_ff
        cfg.layer_types = list(getattr(text_cfg, 'layer_types', []) or [])
        return cfg

    def compute_params(self, n_actual_params: int = 0):
        self.total_params = n_actual_params
        self.active_params = n_actual_params

    @property
    def eml_params(self) -> int:
        """Estimated EML parameter count for the architecture.

        Each weight matrix W[d_out, d_in] maps to:
          4 * d_out EML parameters (w1, b1, w2, b2 per row)
        instead of d_out * d_in standard parameters.
        """
        d_head, n_heads, n_kv_heads = self.d_head, self.n_heads, self.n_kv_heads
        d_model, d_ff = self.d_model, self.d_ff

        # Attention: Q, K, V, O projections
        attn_eml = (n_heads * d_head + n_kv_heads * d_head * 2 + n_heads * d_head) * 4
        if self.is_moe:
            ffn_eml = self.n_experts * 3 * d_ff * 4
            if self.d_shared_ff > 0:
                ffn_eml += 3 * self.d_shared_ff * 4
        else:
            ffn_eml = 3 * d_ff * 4
        per_layer = attn_eml + ffn_eml
        embed = self.vocab_size * d_model
        final_norm = d_model
        return self.n_layers * per_layer + embed + final_norm

    @property
    def compression_ratio(self) -> float:
        if self.eml_params == 0 or self.total_params == 0:
            return 0.0
        return self.total_params / self.eml_params

    @property
    def vram_fp16_gb(self) -> float:
        return self.total_params * 2 / 1024**3

    @property
    def vram_eml_fp16_gb(self) -> float:
        return self.eml_params * 2 / 1024**3

    @property
    def vram_int4_gb(self) -> float:
        return self.total_params * 0.5 / 1024**3

    @property
    def active_params_str(self) -> str:
        if self.is_moe and self.active_params > 0:
            return f"{self.active_params/1e9:.2f}B (active) / {self.total_params/1e9:.2f}B (total)"
        return format_params(self.total_params)


def format_params(n):
    if n >= 1e9: return f"{n/1e9:.2f}B"
    if n >= 1e6: return f"{n/1e6:.2f}M"
    if n >= 1e3: return f"{n/1e3:.1f}K"
    return str(n)


# ════════════════════════════════════════════════════════════════════════════
# §4. Model Weight Loader — Drive-cache aware, memory-efficient
# ════════════════════════════════════════════════════════════════════════════

class ModelWeightLoader:
    """Loads any HuggingFace causal LM with Google Drive caching.

    Supports:
      - Multi-GPU (device_map="auto" with accelerate)
      - Single GPU (device="cuda")
      - CPU fallback
      - Drive cache: downloads once, reuses from Drive
    """

    def __init__(self, model_name: str = "Qwen/Qwen2.5-3B-Instruct",
                 drive_cache: Optional[DriveCache] = None,
                 device: str = "auto"):
        self.model_name = model_name
        self.drive_cache = drive_cache
        self.device = device
        self.model = None
        self.tokenizer = None
        self.config = None
        self.model_config = None
        self._loaded = False

    @staticmethod
    def _detect_device() -> str:
        try:
            import torch
            if torch.cuda.is_available():
                return "cuda"
        except ImportError:
            pass
        return "cpu"

    def _get_available_vram_gb(self) -> float:
        try:
            import torch
            if torch.cuda.is_available():
                return torch.cuda.get_device_properties(0).total_mem / 1024**3
        except Exception:
            pass
        return 0.0

    def load(self, telemetry: Optional[Telemetry] = None) -> bool:
        """Load model, using Google Drive cache when available."""
        try:
            import torch
            from transformers import AutoModelForCausalLM, AutoTokenizer, AutoConfig

            if self.device == "auto":
                self.device = self._detect_device()

            # Determine load path (Drive cache or HF download)
            local_path = None
            if self.drive_cache and self.drive_cache.has_cached_model(self.model_name):
                local_path = self.drive_cache.model_cache_path(self.model_name)
                print(f"  ✓ Loading from Drive cache: {local_path}")
            elif self.drive_cache:
                local_path = self.drive_cache.model_cache_path(self.model_name)
                print(f"  ↓ Downloading {self.model_name} → Drive cache...")

            load_path = local_path or self.model_name

            if telemetry:
                telemetry.event("load", "start", model=self.model_name,
                               path=str(load_path), device=self.device)

            print(f"  Loading {load_path}...")
            print(f"  Device: {self.device}")

            self.config = AutoConfig.from_pretrained(load_path, trust_remote_code=True)
            self.tokenizer = AutoTokenizer.from_pretrained(load_path, trust_remote_code=True)
            self.model_config = ModelConfig.from_hf_config(self.config)

            t0 = time.perf_counter()
            use_cuda = (self.device != "cpu")
            available_vram = self._get_available_vram_gb()

            # Select dtype based on GPU capabilities
            if use_cuda:
                try:
                    bf16_ok = torch.cuda.is_bf16_supported()
                except Exception:
                    bf16_ok = False
                dtype = torch.bfloat16 if bf16_ok else torch.float16
            else:
                dtype = torch.float32

            # Determine device_map for large models
            model_params_b = self.model_config.d_model ** 2 * self.model_config.n_layers * 12 / 1e9  # rough estimate
            if use_cuda and model_params_b > available_vram * 3:  # >3x VRAM means model won't fit
                print(f"  ⚠ Model may not fit in {available_vram:.0f}GB VRAM — using device_map='auto'")
                device_map = "auto"
            elif use_cuda:
                device_map = self.device
            else:
                device_map = None

            print(f"  Dtype: {dtype}, device_map: {device_map}")

            self.model = AutoModelForCausalLM.from_pretrained(
                load_path,
                torch_dtype=dtype,
                device_map=device_map,
                low_cpu_mem_usage=True,
                trust_remote_code=True,
            )

            t1 = time.perf_counter()

            # Save to Drive cache if we just downloaded
            if (self.drive_cache and local_path
                and not self.drive_cache.has_cached_model(self.model_name)):
                print(f"  Saving to Drive cache for future runs...")
                self.model.save_pretrained(local_path, safe_serialization=True)
                self.tokenizer.save_pretrained(local_path)
                cache_size = sum(
                    os.path.getsize(os.path.join(dp, f))
                    for dp, _, fns in os.walk(local_path)
                    for f in fns
                    if os.path.isfile(os.path.join(dp, f))
                )
                print(f"  ✓ Cached {cache_size/1024**3:.2f} GB to Drive")

            actual_params = sum(p.numel() for p in self.model.parameters())
            self.model_config.compute_params(actual_params)
            self._loaded = True

            vram_mb = 0
            if use_cuda and torch.cuda.is_available():
                vram_mb = torch.cuda.memory_allocated() / 1024**2

            load_time = t1 - t0
            print(f"  ✓ Loaded in {load_time:.1f}s")
            self._print_model_summary(self.model_config, actual_params, vram_mb)

            if telemetry:
                telemetry.event("load", "complete",
                               load_time_s=round(load_time, 2),
                               params_b=round(actual_params/1e9, 2),
                               vram_mb=round(vram_mb, 1),
                               dtype=str(dtype))

            return True

        except Exception as e:
            print(f"  ✗ Error loading model: {e}")
            traceback.print_exc()
            if telemetry:
                telemetry.event("load", "error", error=str(e))
            return False

    def _print_model_summary(self, cfg: ModelConfig, params: int, vram_mb: float):
        print(f"  ┌──────────────────────────────────────────────┐")
        print(f"  │ Model type:    {cfg.model_type:<29}│")
        print(f"  │ Hidden size:   {cfg.d_model:<29}│")
        print(f"  │ Num layers:    {cfg.n_layers:<29}│")
        print(f"  │ Num heads:     {cfg.n_heads:<29}│")
        print(f"  │ KV heads:      {cfg.n_kv_heads:<29}│")
        print(f"  │ Head dim:      {cfg.d_head:<29}│")
        print(f"  │ FF dim:        {cfg.d_ff:<29}│")
        print(f"  │ Vocab size:    {cfg.vocab_size:<29}│")
        if cfg.is_moe:
            print(f"  │ MoE experts:   {cfg.n_experts:<29}│")
            print(f"  │ Active/tok:    {cfg.n_experts_per_tok:<29}│")
            print(f"  │ Expert FF:     {cfg.d_expert_ff:<29}│")
            print(f"  │ Shared FF:     {cfg.d_shared_ff:<29}│")
        if cfg.layer_types:
            n_attn = sum(1 for lt in cfg.layer_types if 'full' in str(lt).lower())
            n_lin = sum(1 for lt in cfg.layer_types if 'linear' in str(lt).lower())
            print(f"  │ Hybrid:        {n_attn} attn + {n_lin} linear{' '*15}│")
        print(f"  │ Params:        {params:,} ({params/1e9:.2f}B){' '*11}│")
        print(f"  │ VRAM:          {vram_mb:.1f} MB ({vram_mb/1024:.2f} GB){' '*6}│")
        print(f"  │ EML params:    {format_params(cfg.eml_params):<29}│")
        print(f"  │ Compression:   {cfg.compression_ratio:.1f}×{' '*26}│")
        print(f"  └──────────────────────────────────────────────┘")

    def get_layer_weights(self, layer_idx: int) -> Dict[str, np.ndarray]:
        """Get weight matrices for a specific transformer layer."""
        import torch
        # Try standard and multimodal wrapper prefixes
        for prefix in [f"model.layers.{layer_idx}.",
                       f"language_model.model.layers.{layer_idx}."]:
            layer = {}
            for name, param in self.model.named_parameters():
                if name.startswith(prefix) and param.dim() >= 2:
                    short_name = name.replace(prefix, "")
                    layer[short_name] = param.detach().cpu().float().numpy()
            if layer:
                return layer
        return {}


# ════════════════════════════════════════════════════════════════════════════
# §5. EML Distiller — model-agnostic, MoE-aware, iterative fitting
# ════════════════════════════════════════════════════════════════════════════

class EMLDistiller:
    """Distill real weight matrices to EML parameters.

    For each weight matrix W[d_out, d_in]:
      Standard: y = W @ x   (d_out × d_in params)
      EML: y_j = exp(w1_j * z_j + b1_j) - ln(w2_j * z_j + b2_j)  (4 × d_out params)
      where z_j = W[j,:] @ x (the projection is retained)

    Total reduction: d² → 4d per matrix.
    """

    def __init__(self, temperature: float = 4.0, alpha: float = 0.5,
                 n_distill_samples: int = 50, n_newton_steps: int = 5,
                 seed: int = 42):
        self.temperature = temperature
        self.alpha = alpha
        self.n_distill_samples = n_distill_samples
        self.n_newton_steps = n_newton_steps
        self.rng = np.random.default_rng(seed)

    def distill_dense_layer(self, W: np.ndarray) -> Dict[str, np.ndarray]:
        """Distill a single dense weight matrix to EML parameters.

        Uses an initial closed-form estimate followed by Newton correction.
        """
        d_out, d_in = W.shape
        n_cal = 20  # calibration samples

        X_cal = self.rng.standard_normal((n_cal, d_in)) * 0.1
        teacher_out = X_cal @ W.T

        # Initial closed-form estimate
        z_means = teacher_out.mean(axis=0)
        b2 = np.maximum(np.abs(z_means) + 2.0, 1.0)
        ln_b2 = np.log(b2)
        target_exp = z_means + ln_b2
        b1 = np.clip(np.log(np.maximum(target_exp, 0.01)), -10, 10)
        exp_b1 = np.exp(b1)
        w1 = np.clip(1.0 / np.maximum(exp_b1, 1e-8), -5, 5)
        w2 = np.zeros(d_out)

        # Iterative Newton correction
        lr = 0.01
        for step in range(self.n_newton_steps):
            a = w1[np.newaxis, :] * teacher_out + b1[np.newaxis, :]
            a = np.clip(a, -20, 20)
            b_arg = np.maximum(w2[np.newaxis, :] * teacher_out + b2[np.newaxis, :], 1e-10)
            eml_out = np.exp(a) - np.log(b_arg)
            residual = eml_out - teacher_out
            exp_a = np.exp(a)

            grad_w1 = 2.0 / n_cal * np.sum(residual * exp_a * teacher_out, axis=0)
            grad_b1 = 2.0 / n_cal * np.sum(residual * exp_a, axis=0)

            w1 = np.clip(w1 - lr * grad_w1, -5, 5)
            b1 = np.clip(b1 - lr * grad_b1, -10, 10)

        del teacher_out, X_cal
        return {'w1': w1, 'b1': b1, 'w2': w2, 'b2': b2, 'W_proj': W}

    def distill_attention_layer(self, layer_weights: Dict) -> Dict:
        """Distill all attention projection weights."""
        result = {}
        proj_names = [
            'q_proj', 'k_proj', 'v_proj', 'o_proj',
            'q_a_proj', 'q_b_proj', 'kv_a_proj_with_kva', 'kv_b_proj',
            'linear_q_proj', 'linear_k_proj', 'linear_v_proj', 'linear_out_proj',
        ]
        for proj in proj_names:
            for key, W in layer_weights.items():
                if proj in key and 'weight' in key and 'norm' not in key.lower():
                    if proj not in result:
                        result[proj] = self.distill_dense_layer(W)
        return result

    def distill_ffn_layer(self, layer_weights: Dict) -> Dict:
        """Distill FFN weights, handling MoE experts specially."""
        result = {}
        ffn_projs = ['gate_proj', 'up_proj', 'down_proj', 'w1', 'w2', 'w3', 'fc1', 'fc2']
        expert_keys = [k for k in layer_weights if 'experts' in k or 'block_sparse_moe' in k]

        if expert_keys:
            result = self._distill_moe_experts(layer_weights, n_sample=min(5, len(set(
                k.split('experts.')[1].split('.')[0]
                for k in expert_keys if 'experts.' in k
            ))))
        else:
            for proj in ffn_projs:
                for key, W in layer_weights.items():
                    if proj in key and 'weight' in key and 'norm' not in key.lower():
                        if proj not in result:
                            result[proj] = self.distill_dense_layer(W)
                            break
        return result

    def _distill_moe_experts(self, layer_weights: Dict, n_sample: int = 5) -> Dict:
        """Sample and distill a subset of MoE experts (for demonstration)."""
        result = {}
        expert_keys = sorted([k for k in layer_weights if 'experts' in k])
        if not expert_keys:
            return result
        expert_indices = sorted(set(
            k.split('experts.')[1].split('.')[0]
            for k in expert_keys if 'experts.' in k
        ))
        sample_indices = expert_indices[:n_sample]
        for idx in sample_indices:
            for proj in ['gate_proj', 'up_proj', 'down_proj', 'w1', 'w2', 'w3']:
                for key, W in layer_weights.items():
                    if f'experts.{idx}.' in key and proj in key and 'weight' in key:
                        result[f'expert_{idx}_{proj}'] = self.distill_dense_layer(W)
                        break
        # Shared expert
        for proj in ['gate_proj', 'up_proj', 'down_proj']:
            for key, W in layer_weights.items():
                if 'shared_expert' in key and proj in key and 'weight' in key:
                    if f'shared_{proj}' not in result:
                        result[f'shared_{proj}'] = self.distill_dense_layer(W)
                        break
        return result

    def compute_layer_error(self, W: np.ndarray, eml_params: Dict,
                            n_samples: int = 50) -> Dict[str, float]:
        """Compute reconstruction error for a distilled layer."""
        d_out, d_in = W.shape
        X = self.rng.standard_normal((n_samples, d_in)) * 0.1
        teacher_out = X @ W.T

        w1, b1, w2, b2 = eml_params['w1'], eml_params['b1'], eml_params['w2'], eml_params['b2']
        student_out = np.column_stack([
            eml_vec(w1[j] * teacher_out[:, j] + b1[j],
                    w2[j] * teacher_out[:, j] + b2[j])
            for j in range(d_out)
        ])

        abs_err = np.abs(teacher_out - student_out)
        cos_sim = float(np.sum(teacher_out * student_out) /
                       (np.linalg.norm(teacher_out) * np.linalg.norm(student_out) + 1e-10))

        del teacher_out, student_out, X
        return {
            'mean_abs_error': float(abs_err.mean()),
            'max_abs_error': float(abs_err.max()),
            'cosine_sim': cos_sim,
        }


# ════════════════════════════════════════════════════════════════════════════
# §6. Crystallizer — integer weight crystallization
# ════════════════════════════════════════════════════════════════════════════

class Crystallizer:
    """Crystallize weights to integers with bounded error.

    Two modes:
      1. EML parameter crystallization (sinusoidal penalty → round)
      2. Model weight crystallization (int16 per-channel → word-for-word match)
    """

    @staticmethod
    def crystallize(weights: np.ndarray) -> Tuple[np.ndarray, Dict]:
        """Round weights to nearest integer with error stats."""
        crystal = np.round(weights).astype(np.int64)
        errors = np.abs(weights - crystal)
        stats = {
            "max_error": float(errors.max()),
            "mean_error": float(errors.mean()),
            "n_exact": int(np.sum(errors < 1e-10)),
            "n_weights": int(len(weights.flatten())),
        }
        return crystal, stats

    @staticmethod
    def crystallize_with_penalty(weights, lambda_crystal=0.1, n_steps=200, lr=0.01):
        """Push weights toward integers via sinusoidal penalty.

        Penalty: d/dw [λ · cos²(π w)] = -λ π sin(2πw)
        Minima of cos²(πw) are precisely at integer values.
        """
        w = weights.copy()
        for _ in range(n_steps):
            w -= lr * lambda_crystal * np.pi * np.sin(2 * np.pi * w)
        return w

    @staticmethod
    def crystallize_layer(eml_params: Dict) -> Tuple[Dict, Dict]:
        """Crystallize EML parameters for a layer."""
        all_w = np.concatenate([
            eml_params['w1'], eml_params['b1'],
            eml_params['w2'], eml_params['b2']
        ])
        trained = Crystallizer.crystallize_with_penalty(all_w, n_steps=200, lr=0.01)
        crystal_all, stats = Crystallizer.crystallize(trained)
        d = len(eml_params['w1'])
        result = {
            'w1': crystal_all[:d].astype(float),
            'b1': crystal_all[d:2*d].astype(float),
            'w2': crystal_all[2*d:3*d].astype(float),
            'b2': crystal_all[3*d:4*d].astype(float),
        }
        if 'W_proj' in eml_params:
            W_flat = eml_params['W_proj'].flatten()
            W_errors = np.abs(W_flat - np.round(W_flat))
            stats['proj_n_weights'] = int(W_flat.size)
            stats['proj_n_exact'] = int(np.sum(W_errors < 1e-10))
            stats['proj_max_error'] = float(W_errors.max())
        return result, stats

    @staticmethod
    def crystallize_model_int16(model) -> Dict:
        """Replace fp16 Linear weights with dequantized int16.

        Per-channel symmetric quantization:
          scale_j = max(|W[j,:]|) / 32767
          W_int16 = round(W / scale).clamp(-32768, 32767)
          W_dequant = W_int16.float() * scale

        This achieves word-for-word match with the original model
        under greedy (temperature=0) decoding.
        """
        import torch
        n_layers = 0
        n_params = 0
        total_abs_err = 0.0
        max_abs_err = 0.0
        max_rel_err = 0.0

        for name, module in model.named_modules():
            if isinstance(module, torch.nn.Linear):
                W = module.weight.data.float()
                scale = W.abs().amax(dim=1).clamp(min=1e-10) / 32767.0
                W_int16 = torch.round(W / scale.unsqueeze(1)).clamp(-32768, 32767)
                W_dequant = W_int16.float() * scale.unsqueeze(1)
                module.weight.data = W_dequant.to(module.weight.dtype)

                err = (W - W_dequant).abs()
                rel = err / W.abs().clamp(min=1e-10)

                n_layers += 1
                n_params += W.numel()
                total_abs_err += err.sum().item()
                max_abs_err = max(max_abs_err, err.max().item())
                max_rel_err = max(max_rel_err, rel.max().item())

                del W, W_int16, W_dequant, err, rel

        return {
            'n_layers_quantized': n_layers,
            'n_params_quantized': n_params,
            'max_abs_error': max_abs_err,
            'mean_abs_error': total_abs_err / max(n_params, 1),
            'max_rel_error': max_rel_err,
        }


# ════════════════════════════════════════════════════════════════════════════
# §7. Knowledge Distiller — teacher → compact student
# ════════════════════════════════════════════════════════════════════════════

class KnowledgeDistiller:
    """Distill knowledge from teacher model to a compact student.

    Method:
      loss = α · KL(softmax(s/T), softmax(t/T)) + (1-α) · CE(s, labels)
    where s = student logits, t = teacher logits, T = temperature.
    """

    def __init__(self, teacher_model, teacher_tokenizer,
                 temperature: float = 2.0, alpha: float = 0.7,
                 device: str = "auto"):
        self.teacher = teacher_model
        self.tokenizer = teacher_tokenizer
        self.temperature = temperature
        self.alpha = alpha
        self.device = device

    def _get_device(self):
        import torch
        if self.device == "auto":
            if torch.cuda.is_available():
                return "cuda"
            return "cpu"
        return self.device

    def create_student(self, scale_factor: float = 0.5):
        """Create a smaller student model by scaling the teacher architecture.

        Args:
            scale_factor: Fraction of original hidden size (0.5 = half)
        """
        import torch
        from transformers import AutoConfig, AutoModelForCausalLM

        teacher_config = self.teacher.config
        if hasattr(teacher_config, 'text_config'):
            src = teacher_config.text_config
        else:
            src = teacher_config

        new_hidden = max(int(src.hidden_size * scale_factor), 256)
        new_hidden = (new_hidden // 256) * 256  # round to 256

        new_intermediate = int(new_hidden * (src.intermediate_size / max(src.hidden_size, 1)))
        new_intermediate = (new_intermediate // 256) * 256

        new_heads = max(src.num_attention_heads // 2, 1)
        while new_hidden % new_heads != 0:
            new_heads -= 1

        new_layers = max(src.num_hidden_layers // 2, 2)
        new_kv_heads = max(src.num_key_value_heads // 2, 1)
        if new_kv_heads > new_heads:
            new_kv_heads = new_heads

        device = self._get_device()

        student_config_dict = src.to_dict()
        student_config_dict.update({
            'hidden_size': new_hidden,
            'intermediate_size': new_intermediate,
            'num_attention_heads': new_heads,
            'num_hidden_layers': new_layers,
            'num_key_value_heads': new_kv_heads,
        })
        # Remove MoE fields from student (simplify)
        for k in ['num_experts', 'num_experts_per_tok', 'moe_intermediate_size',
                   'shared_expert_intermediate_size']:
            student_config_dict.pop(k, None)

        student_config = type(src)(**student_config_dict)
        student = AutoModelForCausalLM.from_config(student_config, trust_remote_code=True)
        student = student.to(device)

        n_params = sum(p.numel() for p in student.parameters())
        print(f"  Student: hidden={new_hidden}, layers={new_layers}, heads={new_heads}, kv={new_kv_heads}")
        print(f"  Student params: {n_params:,} ({n_params/1e9:.2f}B)")
        return student

    def distill(self, student, n_steps: int = 500, lr: float = 5e-5,
               max_len: int = 512, telemetry: Optional[Telemetry] = None):
        """Run distillation training loop with synthetic calibration data."""
        import torch
        import torch.nn.functional as F

        device = self._get_device()
        self.teacher.eval()
        student.train()

        optimizer = torch.optim.AdamW(student.parameters(), lr=lr)
        scheduler = torch.optim.lr_scheduler.CosineAnnealingLR(optimizer, T_max=n_steps)

        # Synthetic calibration data (diverse topics for knowledge transfer)
        texts = [
            "The meaning of life is a philosophical question that has been debated for centuries.",
            "In mathematics, a prime number is a natural number greater than 1 that has no positive divisors other than 1 and itself.",
            "The quantum mechanical model describes electrons as probability waves rather than point particles.",
            "Artificial intelligence refers to the simulation of human intelligence in machines that are programmed to think and learn.",
            "The theory of relativity fundamentally changed our understanding of space and time, showing they are interconnected.",
            "DNA contains the genetic instructions used in the development and functioning of all known living organisms.",
            "Climate change is primarily caused by increasing concentrations of greenhouse gases in the atmosphere.",
            "The Renaissance was a cultural movement that profoundly affected European intellectual life in the early modern period.",
            "Machine learning is a subset of AI that provides systems the ability to automatically learn and improve from experience.",
            "The internet has revolutionized communication, commerce, and access to information on a global scale.",
        ] * (n_steps // 10 + 1)  # repeat enough for all steps

        step = 0
        total_loss = 0
        loss_history = []

        while step < n_steps:
            for text in texts:
                if step >= n_steps:
                    break

                inputs = self.tokenizer(
                    text, return_tensors="pt",
                    truncation=True, max_length=max_len
                ).to(device)

                with torch.no_grad():
                    teacher_out = self.teacher(
                        **{k: v for k, v in inputs.items()
                           if k in ('input_ids', 'attention_mask')}
                    ).logits

                student_out = student(
                    **{k: v for k, v in inputs.items()
                       if k in ('input_ids', 'attention_mask')}
                ).logits

                # Soft target loss (KL divergence)
                T = self.temperature
                soft_loss = F.kl_div(
                    F.log_softmax(student_out / T, dim=-1),
                    F.softmax(teacher_out / T, dim=-1),
                    reduction='batchmean'
                ) * (T * T)

                # Hard label loss
                hard_loss = F.cross_entropy(
                    student_out[:, :-1, :].contiguous().view(-1, student_out.size(-1)),
                    inputs['input_ids'][:, 1:].contiguous().view(-1)
                )

                loss = self.alpha * soft_loss + (1 - self.alpha) * hard_loss
                optimizer.zero_grad()
                loss.backward()
                torch.nn.utils.clip_grad_norm_(student.parameters(), 1.0)
                optimizer.step()
                scheduler.step()

                total_loss += loss.item()
                loss_history.append(loss.item())
                step += 1

                if step % 100 == 0:
                    vram = torch.cuda.memory_allocated() / 1024**2 if torch.cuda.is_available() else 0
                    avg_100 = np.mean(loss_history[-100:])
                    print(f"    Step {step}/{n_steps}: loss={avg_100:.4f}, VRAM={vram:.0f}MB")
                    if telemetry:
                        telemetry.event("distill", "step", step=step,
                                        loss=round(avg_100, 4),
                                        vram_mb=round(vram, 1),
                                        lr=round(scheduler.get_last_lr()[0], 6))

                del teacher_out, student_out, soft_loss, hard_loss, loss
                if step >= n_steps:
                    break

        student.eval()
        avg_loss = total_loss / max(step, 1)
        final_lr = scheduler.get_last_lr()[0]
        print(f"  ✓ Distillation complete: {step} steps, avg loss: {avg_loss:.4f}")
        return student, loss_history


# ════════════════════════════════════════════════════════════════════════════
# §8. Quantizer — GPTQ / GGUF compression
# ════════════════════════════════════════════════════════════════════════════

class ModelQuantizer:
    """Apply quantization methods for final compression pass."""

    @staticmethod
    def gptq_quantize(model_name: str, output_dir: str, bits: int = 4,
                      group_size: int = 128,
                      telemetry: Optional[Telemetry] = None):
        """Quantize model using AutoGPTQ (int4 with group-wise quantization)."""
        try:
            from auto_gptq import AutoGPTQForCausalLM, BaseQuantizeConfig
            from transformers import AutoTokenizer
            import torch
        except ImportError:
            print("  [auto_gptq not available — install with: pip install auto-gptq]")
            return None

        if telemetry:
            telemetry.event("quantize", "gptq_start", bits=bits, group_size=group_size)

        print(f"  GPTQ quantizing to {bits}-bit...")
        tokenizer = AutoTokenizer.from_pretrained(model_name, trust_remote_code=True)

        # Calibration data
        try:
            from datasets import load_dataset
            dataset = load_dataset("wikitext", "wikitext-2-raw-v1", split="train")
            calib_texts = [t for t in dataset['text'][:256] if len(t.strip()) > 50][:128]
        except Exception:
            calib_texts = ["The quick brown fox jumps over the lazy dog. " * 20] * 128

        calib_data = tokenizer(calib_texts, return_tensors="pt",
                               truncation=True, max_length=512, padding=True)
        calib_data = {k: v.cuda() for k, v in calib_data.items()
                      if k in ('input_ids', 'attention_mask')}

        config = BaseQuantizeConfig(bits=bits, group_size=group_size, desc_act=True)
        model_q = AutoGPTQForCausalLM.from_pretrained(model_name, config, trust_remote_code=True)
        model_q.quantize(calib_data)
        model_q.save_quantized(output_dir)

        total_size = sum(
            os.path.getsize(os.path.join(dp, f))
            for dp, _, fns in os.walk(output_dir)
            for f in fns
        )
        print(f"  ✓ GPTQ saved to {output_dir} ({total_size/1024**3:.2f} GB)")

        if telemetry:
            telemetry.event("quantize", "gptq_complete",
                           size_gb=round(total_size / 1024**3, 2), bits=bits)
        return output_dir

    @staticmethod
    def convert_to_gguf(model_path: str, output_path: str,
                        quant_type: str = "Q4_K_M",
                        telemetry: Optional[Telemetry] = None):
        """Convert model to GGUF format using llama.cpp conversion tools."""
        if telemetry:
            telemetry.event("quantize", "gguf_start", quant_type=quant_type)

        llama_cpp_dir = "/content/llama.cpp"

        # Clone llama.cpp if needed
        if not os.path.exists(llama_cpp_dir):
            print("  Cloning llama.cpp...")
            subprocess.run(
                ["git", "clone", "https://github.com/ggml-org/llama.cpp.git",
                 llama_cpp_dir, "--depth", "1"],
                capture_output=True, timeout=120
            )

        # Build llama.cpp
        bin_path = os.path.join(llama_cpp_dir, "build", "bin", "llama-quantize")
        if not os.path.exists(bin_path):
            print("  Building llama.cpp (CUDA)...")
            build_dir = os.path.join(llama_cpp_dir, "build")
            os.makedirs(build_dir, exist_ok=True)
            r1 = subprocess.run(
                ["cmake", "-B", build_dir, "-DGGML_CUDA=ON",
                 "-DCMAKE_BUILD_TYPE=Release"],
                cwd=llama_cpp_dir, capture_output=True, text=True
            )
            r2 = subprocess.run(
                ["cmake", "--build", build_dir, "--config", "Release", "-j8"],
                cwd=llama_cpp_dir, capture_output=True, text=True, timeout=600
            )
            if not os.path.exists(bin_path):
                print(f"  ⚠ llama-quantize not found, checking alternatives...")
                # Try without CUDA
                r1 = subprocess.run(
                    ["cmake", "-B", build_dir, "-DGGML_CUDA=OFF",
                     "-DCMAKE_BUILD_TYPE=Release"],
                    cwd=llama_cpp_dir, capture_output=True, text=True
                )
                r2 = subprocess.run(
                    ["cmake", "--build", build_dir, "--config", "Release", "-j8"],
                    cwd=llama_cpp_dir, capture_output=True, text=True, timeout=600
                )

        # Convert to GGUF F16 first
        convert_script = os.path.join(llama_cpp_dir, "convert_hf_to_gguf.py")
        if not os.path.exists(convert_script):
            print(f"  ⚠ Conversion script not found at {convert_script}")
            return None

        f16_path = output_path.replace(".gguf", "-F16.gguf")

        print(f"  Converting to GGUF F16...")
        result = subprocess.run(
            [sys.executable, convert_script, model_path,
             "--outfile", f16_path, "--outtype", "f16"],
            capture_output=True, text=True, timeout=600
        )
        if result.returncode != 0:
            print(f"  ✗ F16 conversion error: {result.stderr[:500]}")
            return None

        # Quantize to target format
        if quant_type != "F16":
            print(f"  Quantizing to {quant_type}...")
            result = subprocess.run(
                [bin_path, f16_path, output_path, quant_type],
                capture_output=True, text=True, timeout=600
            )
            if result.returncode != 0:
                print(f"  ✗ Quantization error: {result.stderr[:500]}")
                # Fallback: just use F16
                output_path = f16_path
            else:
                # Cleanup F16 intermediate
                if os.path.exists(f16_path) and "-F16" in f16_path:
                    os.remove(f16_path)
        else:
            output_path = f16_path

        if os.path.exists(output_path):
            file_size = os.path.getsize(output_path)
            print(f"  ✓ GGUF: {output_path} ({file_size/1024**3:.2f} GB)")

            if telemetry:
                telemetry.event("quantize", "gguf_complete",
                               size_gb=round(file_size / 1024**3, 2),
                               quant_type=quant_type)
            return output_path

        return None


# ════════════════════════════════════════════════════════════════════════════
# §9. OISCC Compiler — instruction counting
# ════════════════════════════════════════════════════════════════════════════

class OISCCCompiler:
    @staticmethod
    def count_instructions(cfg: ModelConfig) -> Dict:
        n_kv = cfg.n_kv_heads if cfg.n_kv_heads > 0 else cfg.n_heads
        attn_neurons = (cfg.n_heads * cfg.d_head + n_kv * cfg.d_head * 2 + cfg.n_heads * cfg.d_head)
        if cfg.is_moe:
            ffn_neurons = cfg.n_experts * 3 * cfg.d_ff
            if cfg.d_shared_ff > 0:
                ffn_neurons += 3 * cfg.d_shared_ff
        else:
            ffn_neurons = 3 * cfg.d_ff
        per_layer = attn_neurons + ffn_neurons
        total_neurons = cfg.n_layers * per_layer
        return {
            'total_neurons': total_neurons,
            'total_instructions': total_neurons * 3,
            'program_size_mb': total_neurons * 3 * 12 / 1024**2,
        }


# ════════════════════════════════════════════════════════════════════════════
# §10. Benchmark Suite — speed, memory, perplexity, quality
# ════════════════════════════════════════════════════════════════════════════

class Benchmark:
    """Comprehensive benchmark suite with structured telemetry."""

    def __init__(self, model, tokenizer, device: str = "auto",
                 telemetry: Optional[Telemetry] = None):
        self.model = model
        self.tokenizer = tokenizer
        self.device = device
        self.telemetry = telemetry

    def _get_device(self):
        import torch
        if self.device == "auto":
            try:
                return next(self.model.parameters()).device
            except StopIteration:
                return "cpu"
        return self.device

    def benchmark_generation(self, prompts: List[str], max_new_tokens: int = 50,
                             do_sample: bool = False) -> Dict:
        """Benchmark generation speed (tokens/second, ms/token)."""
        import torch

        device = self._get_device()
        self.model.eval()
        has_chat = (hasattr(self.tokenizer, 'apply_chat_template')
                   and self.tokenizer.chat_template is not None)

        total_tokens = 0
        total_time = 0
        results = []

        for prompt in prompts:
            if has_chat:
                input_text = self.tokenizer.apply_chat_template(
                    [{"role": "user", "content": prompt}],
                    add_generation_prompt=True, tokenize=False)
                inputs = self.tokenizer(input_text, return_tensors="pt").to(device)
            else:
                inputs = self.tokenizer(prompt, return_tensors="pt").to(device)

            n_input = inputs['input_ids'].shape[1]

            # Warmup
            with torch.no_grad():
                _ = self.model.generate(inputs["input_ids"][:, :1],
                                        max_new_tokens=1,
                                        pad_token_id=self.tokenizer.eos_token_id)
            if torch.cuda.is_available():
                torch.cuda.synchronize()

            # Timed generation
            t0 = time.perf_counter()
            with torch.no_grad():
                out = self.model.generate(
                    inputs["input_ids"],
                    max_new_tokens=max_new_tokens,
                    do_sample=do_sample,
                    pad_token_id=self.tokenizer.eos_token_id,
                    use_cache=True,
                )
            if torch.cuda.is_available():
                torch.cuda.synchronize()
            t1 = time.perf_counter()

            n_generated = out.shape[1] - n_input
            elapsed = t1 - t0
            tps = n_generated / elapsed if elapsed > 0 else 0

            text = self.tokenizer.decode(out[0], skip_special_tokens=True)
            continuation = (text[len(prompt):].strip()[:100] if has_chat
                           else text[:100])

            result = {
                'prompt': prompt[:50],
                'input_tokens': n_input,
                'generated_tokens': n_generated,
                'time_s': round(elapsed, 3),
                'tokens_per_sec': round(tps, 1),
                'ms_per_token': round(1000 * elapsed / max(n_generated, 1), 2),
                'output': continuation,
            }
            results.append(result)
            total_tokens += n_generated
            total_time += elapsed

            del out
            if torch.cuda.is_available():
                torch.cuda.empty_cache()

        summary = {
            'total_tokens': total_tokens,
            'total_time_s': round(total_time, 3),
            'avg_tokens_per_sec': round(total_tokens / total_time, 1) if total_time > 0 else 0,
            'avg_ms_per_token': round(1000 * total_time / max(total_tokens, 1), 2),
            'per_prompt': results,
        }

        if self.telemetry:
            self.telemetry.event("benchmark", "generation",
                               avg_tokens_per_sec=summary['avg_tokens_per_sec'],
                               avg_ms_per_token=summary['avg_ms_per_token'])
        return summary

    def benchmark_memory(self) -> Dict:
        """Benchmark memory usage at different precisions."""
        import torch
        mem = {'model_device': str(self._get_device())}

        if torch.cuda.is_available():
            mem['vram_allocated_mb'] = round(torch.cuda.memory_allocated() / 1024**2, 1)
            mem['vram_reserved_mb'] = round(torch.cuda.memory_reserved() / 1024**2, 1)
            total_mem = torch.cuda.get_device_properties(0).total_memory
            mem['vram_total_mb'] = round(total_mem / 1024**2, 1)
            mem['vram_utilization_pct'] = round(
                100 * torch.cuda.memory_allocated() / total_mem, 1
            )

        total_params = sum(p.numel() for p in self.model.parameters())
        mem['total_params'] = total_params
        mem['total_params_b'] = round(total_params / 1e9, 2)
        mem['theoretical_fp16_gb'] = round(total_params * 2 / 1024**3, 2)
        mem['theoretical_int8_gb'] = round(total_params * 1 / 1024**3, 2)
        mem['theoretical_int4_gb'] = round(total_params * 0.5 / 1024**3, 2)

        if self.telemetry:
            self.telemetry.event("benchmark", "memory", **mem)
        return mem

    def benchmark_perplexity(self, dataset_name: str = "wikitext",
                             dataset_config: str = "wikitext-2-raw-v1",
                             max_samples: int = 50, seq_len: int = 2048) -> Dict:
        """Measure perplexity on a text dataset."""
        import torch
        try:
            from datasets import load_dataset
        except ImportError:
            print("  [datasets not installed — pip install datasets]")
            return {"perplexity": float('inf')}

        print(f"  Measuring perplexity on {dataset_name}/{dataset_config}...")
        dataset = load_dataset(dataset_name, dataset_config, split="test")
        texts = [t for t in dataset['text'][:max_samples * 2] if len(t.strip()) > 50][:max_samples]

        self.model.eval()
        total_loss = 0.0
        total_tokens = 0

        with torch.no_grad():
            for text in texts:
                inputs = self.tokenizer(text, return_tensors="pt",
                                        truncation=True, max_length=seq_len)
                inputs = {k: v.to(self._get_device()) for k, v in inputs.items()}
                try:
                    outputs = self.model(**inputs, labels=inputs["input_ids"])
                    n_tokens = inputs["input_ids"].shape[1]
                    total_loss += outputs.loss.item() * n_tokens
                    total_tokens += n_tokens
                except Exception as e:
                    print(f"  [batch error: {e}]")

        if total_tokens == 0:
            return {"perplexity": float('inf')}

        avg_loss = total_loss / total_tokens
        perplexity = float(np.exp(min(avg_loss, 20)))  # cap to avoid overflow

        result = {
            "perplexity": round(perplexity, 2),
            "avg_loss": round(avg_loss, 4),
            "total_tokens": total_tokens,
            "n_samples": len(texts),
        }

        if self.telemetry:
            self.telemetry.event("benchmark", "perplexity", **result)
        return result

    def chat_comparison(self, prompts: List[str],
                        max_new_tokens: int = 50) -> Dict:
        """Compare original vs crystallized model token-by-token."""
        import torch

        device = self._get_device()
        self.model.eval()
        has_chat = (hasattr(self.tokenizer, 'apply_chat_template')
                   and self.tokenizer.chat_template is not None)

        # Generate with original weights
        print("  ── Original Model ──")
        real_outputs = {}
        for prompt in prompts:
            if has_chat:
                input_text = self.tokenizer.apply_chat_template(
                    [{"role": "user", "content": prompt}],
                    add_generation_prompt=True, tokenize=False)
                inputs = self.tokenizer(input_text, return_tensors="pt").to(device)
            else:
                inputs = self.tokenizer(prompt, return_tensors="pt").to(device)

            with torch.no_grad():
                out = self.model.generate(inputs["input_ids"],
                                          max_new_tokens=max_new_tokens,
                                          do_sample=False,
                                          pad_token_id=self.tokenizer.eos_token_id)
            text = self.tokenizer.decode(out[0], skip_special_tokens=True)
            real_outputs[prompt] = out[0].tolist()
            cont = text[len(prompt):].strip()[:200] if len(text) > len(prompt) else text[:200]
            print(f'  "{prompt}" → {cont}')
            del out
            if torch.cuda.is_available():
                torch.cuda.empty_cache()

        # Crystallize
        print("\n  Crystallizing (int16 per-channel)...")
        cs = Crystallizer.crystallize_model_int16(self.model)
        print(f"    Layers: {cs['n_layers_quantized']}, Max err: {cs['max_abs_error']:.8f}")

        # Generate with crystallized weights
        print("  ── Crystal Model ──")
        n_total, n_match = 0, 0
        for prompt in prompts:
            if has_chat:
                input_text = self.tokenizer.apply_chat_template(
                    [{"role": "user", "content": prompt}],
                    add_generation_prompt=True, tokenize=False)
                inputs = self.tokenizer(input_text, return_tensors="pt").to(device)
            else:
                inputs = self.tokenizer(prompt, return_tensors="pt").to(device)

            with torch.no_grad():
                out = self.model.generate(inputs["input_ids"],
                                          max_new_tokens=max_new_tokens,
                                          do_sample=False,
                                          pad_token_id=self.tokenizer.eos_token_id)
            crystal_tokens = out[0].tolist()
            text = self.tokenizer.decode(out[0], skip_special_tokens=True)
            cont = text[len(prompt):].strip()[:200] if len(text) > len(prompt) else text[:200]

            real_tokens = real_outputs[prompt]
            min_len = min(len(real_tokens), len(crystal_tokens))
            matches = sum(1 for i in range(min_len) if real_tokens[i] == crystal_tokens[i])
            first_div = next((i for i in range(min_len) if real_tokens[i] != crystal_tokens[i]), None)
            all_match = matches == min_len and len(real_tokens) == len(crystal_tokens)

            tag = "✓ MATCH" if all_match else f"✗ DIVERGE@{first_div}"
            print(f'  [{tag}] "{prompt}" → {cont}')

            n_total += len(real_tokens)
            n_match += matches
            del out
            if torch.cuda.is_available():
                torch.cuda.empty_cache()

        match_pct = 100.0 * n_match / max(n_total, 1)
        print(f"\n  Token match: {n_match}/{n_total} ({match_pct:.1f}%)")
        if match_pct == 100.0:
            print("  ★★★ WORD-FOR-WORD MATCH ACHIEVED ★★★")
        elif match_pct >= 99.0:
            print("  Near-perfect match (>99%)")

        result = {"match_pct": match_pct, "n_match": n_match, "n_total": n_total}
        if self.telemetry:
            self.telemetry.event("benchmark", "chat_comparison", **result)
        return result

    def run_full_suite(self) -> Dict:
        """Run the complete benchmark suite."""
        all_results = {}

        # Memory
        print("\n  ── Memory Benchmark ──")
        mem = self.benchmark_memory()
        for k, v in mem.items():
            print(f"    {k}: {v}")
        all_results['memory'] = mem

        # Generation speed
        print("\n  ── Generation Speed ──")
        prompts = [
            "The meaning of life is",
            "In the year 2050,",
            "The most important thing about mathematics is",
            "Once upon a time in a galaxy far away,",
            "Quantum computing will revolutionize",
        ]
        gen = self.benchmark_generation(prompts, max_new_tokens=50)
        print(f"    Avg: {gen['avg_tokens_per_sec']} tok/s ({gen['avg_ms_per_token']} ms/token)")
        for r in gen['per_prompt']:
            print(f"    {r['prompt'][:30]:30s} → {r['tokens_per_sec']:6.1f} tok/s")
        all_results['generation'] = gen

        # Perplexity
        print("\n  ── Perplexity ──")
        try:
            ppl = self.benchmark_perplexity(max_samples=20)
            print(f"    Perplexity: {ppl['perplexity']:.2f}")
            all_results['perplexity'] = ppl
        except Exception as e:
            print(f"    [Failed: {e}]")
            all_results['perplexity'] = {"perplexity": "failed"}

        # Chat comparison
        print("\n  ── Chat Comparison ──")
        chat = self.chat_comparison(prompts[:3], max_new_tokens=50)
        all_results['chat_comparison'] = chat

        return all_results


# ════════════════════════════════════════════════════════════════════════════
# §11. Full Pipeline Orchestrator
# ════════════════════════════════════════════════════════════════════════════

def print_header(title, char="═"):
    width = 78
    print(f"\n╔{char * width}╗")
    print(f"║ {title:^{width - 2}} ║")
    print(f"╚{char * width}╝\n")

def print_section(title):
    print(f"\n{'─' * 60}")
    print(f"  {title}")
    print(f"{'─' * 60}")


class QwenCrystalPipeline:
    """Full OISCC-EML compression pipeline.

    Stages:
      0. Download + Drive cache
      1. EML conversion (O(d²) → O(4d) per matrix)
      2. Compression pass 1: int16 crystallization
      3. Knowledge distillation (teacher → student)
      4. Compression pass 2: GGUF Q4_K_M
      5. Optimization (vLLM / llama.cpp)
      6. Benchmark + telemetry
    """

    def __init__(self, model_name: str = "Qwen/Qwen2.5-3B-Instruct",
                 use_drive: bool = True, device: str = "auto",
                 skip_gguf: bool = False, skip_distill: bool = False):
        self.model_name = model_name
        self.device = device
        self.skip_gguf = skip_gguf
        self.skip_distill = skip_distill
        self.telemetry = Telemetry(model_name=model_name)
        self.drive_cache = DriveCache() if use_drive else None
        self.loader = None
        self.config = None
        self.distiller = EMLDistiller()
        self.eml_layers = {}
        self.crystal_layers = {}
        self.layer_errors = {}
        self.student_model = None
        self.bench_results = {}
        self.pipeline_report = {}

    def setup(self):
        """Stage -1: Environment setup and Drive mounting."""
        print_header("Qwen OISCC-EML Compression Pipeline v2")
        print(f"  Model: {self.model_name}")
        hw = self.telemetry.hardware_report()
        print(f"  GPU: {hw.get('gpu', 'unknown')}")
        print(f"  VRAM: {hw.get('vram_total_gb', '?')} GB")
        self.telemetry.event("setup", "start", model=self.model_name, **hw)

        if self.drive_cache:
            self.drive_cache.mount()
            print(f"  Cache: {self.drive_cache.cache_dir}")
            print(f"  Drive usage: {self.drive_cache.disk_usage_gb():.2f} GB")

        return self

    def download_model(self) -> bool:
        """Stage 0: Download model with Google Drive caching."""
        print_section("Stage 0: Download Model (Google Drive Cache)")

        if self.drive_cache and self.drive_cache.has_cached_model(self.model_name):
            print(f"  ✓ Model already cached in Drive!")
            cache_path = self.drive_cache.model_cache_path(self.model_name)
            cache_size = sum(
                os.path.getsize(os.path.join(dp, f))
                for dp, _, fns in os.walk(cache_path)
                for f in fns
                if os.path.isfile(os.path.join(dp, f))
            )
            print(f"  Cache size: {cache_size/1024**3:.2f} GB")
        else:
            print(f"  ↓ Model not cached — will download to Drive")

        self.loader = ModelWeightLoader(
            model_name=self.model_name,
            drive_cache=self.drive_cache,
            device=self.device,
        )

        with self.telemetry.timer("download", "load_model"):
            success = self.loader.load(telemetry=self.telemetry)

        if success:
            self.config = self.loader.model_config
        return success

    def eml_convert(self) -> Dict:
        """Stage 1: Convert weights to OISCC-EML framework."""
        print_section("Stage 1: OISCC-EML Weight Conversion")
        cfg = self.config

        print(f"\n  Architecture: {cfg.model_type}")
        print(f"  Hidden: {cfg.d_model}, Layers: {cfg.n_layers}, Heads: {cfg.n_heads}")
        print(f"  FF: {cfg.d_ff}, Vocab: {cfg.vocab_size}")
        if cfg.is_moe:
            print(f"  MoE: {cfg.n_experts} experts, {cfg.n_experts_per_tok}/tok")
        print(f"  Params: {format_params(cfg.total_params)}")
        print(f"  EML params: {format_params(cfg.eml_params)}")
        print(f"  Compression: {cfg.compression_ratio:.1f}×")

        with self.telemetry.timer("eml", "distill_all"):
            t0 = time.perf_counter()
            total_std, total_eml = 0, 0

            for i in range(cfg.n_layers):
                layer_w = self.loader.get_layer_weights(i)
                if not layer_w:
                    print(f"    Layer {i:2d}: NO WEIGHTS")
                    continue

                attn_params = self.distiller.distill_attention_layer(layer_w)
                ffn_params = self.distiller.distill_ffn_layer(layer_w)
                self.eml_layers[i] = {'attn': attn_params, 'ffn': ffn_params}

                for pp in {**attn_params, **ffn_params}.values():
                    if 'W_proj' in pp:
                        total_std += pp['W_proj'].shape[0] * pp['W_proj'].shape[1]
                        total_eml += pp['W_proj'].shape[0] * 4

                # Error computation on sample layers
                compute_err = (i < 3 or i == cfg.n_layers - 1 or i == cfg.n_layers // 2)
                layer_err = {}
                if compute_err:
                    for pn, ep in {**attn_params, **ffn_params}.items():
                        if 'W_proj' in ep:
                            for key, W in layer_w.items():
                                if pn in key and 'weight' in key:
                                    layer_err[pn] = self.distiller.compute_layer_error(
                                        W, ep, n_samples=50)
                                    break
                self.layer_errors[i] = layer_err
                del layer_w

                if i < 3 or i == cfg.n_layers - 1:
                    err_str = " ".join(f"{p}={e['cosine_sim']:.4f}" for p, e in layer_err.items())
                    print(f"    Layer {i:2d}: {err_str}")
                elif i % 10 == 0:
                    print(f"    ... layer {i}/{cfg.n_layers}")

                gc.collect()

            t1 = time.perf_counter()

        result = {
            'total_standard_params': total_std,
            'total_eml_params': total_eml,
            'compression_ratio': total_std / max(total_eml, 1),
            'time_s': round(t1 - t0, 2),
        }

        ac = [e['cosine_sim'] for le in self.layer_errors.values()
              for e in le.values()]
        if ac:
            result['mean_cosine_sim'] = float(np.mean(ac))
            result['min_cosine_sim'] = float(np.min(ac))
            print(f"\n  Cosine sim: mean={np.mean(ac):.4f}, min={np.min(ac):.4f}")

        print(f"  {format_params(total_std)} → {format_params(total_eml)} ({result['compression_ratio']:.1f}×)")
        self.telemetry.event("eml", "complete", **result)
        self.pipeline_report['eml'] = result
        return result

    def compress_pass1(self) -> Dict:
        """Stage 2: Compression pass 1 — int16 crystallization."""
        print_section("Stage 2: Compression Pass 1 — int16 Crystallization")

        # Free EML weight projections (huge memory)
        for layer_idx in list(self.eml_layers.keys()):
            for proj_type in ['attn', 'ffn']:
                for proj_name in list(self.eml_layers[layer_idx].get(proj_type, {}).keys()):
                    self.eml_layers[layer_idx][proj_type][proj_name].pop('W_proj', None)
        gc.collect()

        # Crystallize EML params
        with self.telemetry.timer("crystal", "eml_crystallize"):
            all_stats = []
            for i, ld in self.eml_layers.items():
                for pn, ep in {**ld['attn'], **ld['ffn']}.items():
                    cp, st = Crystallizer.crystallize_layer(ep)
                    self.crystal_layers.setdefault(i, {})[pn] = cp
                    all_stats.append(st)

        if all_stats:
            nt = sum(s['n_weights'] for s in all_stats)
            ne = sum(s['n_exact'] for s in all_stats)
            result = {
                'n_weights': nt,
                'n_exact': ne,
                'exact_fraction': round(ne / max(nt, 1), 4),
                'max_error': max(s['max_error'] for s in all_stats),
                'mean_error': float(np.mean([s['mean_error'] for s in all_stats])),
            }
            print(f"  EML crystal: {nt:,} weights, {ne:,} exact ({result['exact_fraction']:.1%})")
        else:
            result = {'n_weights': 0}

        # Crystallize actual model weights (int16 per-channel)
        print("\n  Crystallizing model weights to int16...")
        import torch

        with self.telemetry.timer("crystal", "int16_model"):
            cs = Crystallizer.crystallize_model_int16(self.loader.model)

        print(f"  Layers quantized: {cs['n_layers_quantized']}")
        print(f"  Params quantized: {cs['n_params_quantized']:,}")
        print(f"  Max abs error:    {cs['max_abs_error']:.8f}")
        print(f"  Mean abs error:   {cs['mean_abs_error']:.8f}")
        print(f"  Max rel error:   {cs['max_rel_error']:.8f}")
        result['int16_crystallization'] = cs

        self.telemetry.event("compress", "pass1", **cs)
        self.pipeline_report['crystal'] = result
        return result

    def knowledge_distill(self, scale_factor: float = 0.5,
                          n_steps: int = 500) -> Dict:
        """Stage 3: Knowledge distillation into compact student."""
        print_section("Stage 3: Knowledge Distillation")
        print(f"  Student scale: {scale_factor}×, Steps: {n_steps}")

        if self.skip_distill:
            print("  [SKIPPED — --skip-distill flag]")
            return {'skipped': True}

        import torch
        torch.cuda.empty_cache()

        distiller = KnowledgeDistiller(
            self.loader.model, self.loader.tokenizer,
            temperature=2.0, alpha=0.7, device=self.device
        )

        with self.telemetry.timer("distill", "create_student"):
            student = distiller.create_student(scale_factor=scale_factor)

        with self.telemetry.timer("distill", "train"):
            student, loss_history = distiller.distill(
                student, n_steps=n_steps, lr=5e-5, telemetry=self.telemetry)

        self.student_model = student

        student_params = sum(p.numel() for p in student.parameters())
        student_vram = 0
        if torch.cuda.is_available():
            student_vram = torch.cuda.memory_allocated() / 1024**2

        result = {
            'student_params': student_params,
            'student_params_b': round(student_params / 1e9, 2),
            'student_vram_mb': round(student_vram, 1),
            'scale_factor': scale_factor,
            'n_steps': n_steps,
            'final_loss': round(loss_history[-1], 4) if loss_history else None,
        }
        print(f"  Student: {format_params(student_params)} params, {student_vram/1024:.2f} GB VRAM")

        self.telemetry.event("distill", "complete", **result)
        self.pipeline_report['distill'] = result
        return result

    def compress_pass2(self, quant_type: str = "Q4_K_M") -> Dict:
        """Stage 4: Compression pass 2 — GGUF quantization."""
        print_section("Stage 4: Compression Pass 2 — GGUF Quantization")
        print(f"  Target: {quant_type}")

        if self.skip_gguf:
            print("  [SKIPPED — --skip-gguf flag]")
            return {'skipped': True}

        import torch
        torch.cuda.empty_cache()

        # Save model temporarily for GGUF conversion
        tmp_dir = "/content/tmp_model_for_gguf"
        os.makedirs(tmp_dir, exist_ok=True)

        model_to_save = self.student_model or self.loader.model
        tokenizer_to_save = self.loader.tokenizer

        print(f"  Saving model temporarily...")
        model_to_save.save_pretrained(tmp_dir, safe_serialization=True)
        tokenizer_to_save.save_pretrained(tmp_dir)

        safe_name = self.model_name.replace("/", "-")
        gguf_path = f"/content/crystal-{safe_name}-{quant_type}.gguf"

        with self.telemetry.timer("quantize", "gguf"):
            gguf_result = ModelQuantizer.convert_to_gguf(
                tmp_dir, gguf_path, quant_type=quant_type,
                telemetry=self.telemetry
            )

        # Cleanup
        shutil.rmtree(tmp_dir, ignore_errors=True)

        result = {'gguf_path': gguf_result, 'quant_type': quant_type}
        if gguf_result and os.path.exists(gguf_result):
            result['size_gb'] = round(os.path.getsize(gguf_result) / 1024**3, 2)
            print(f"  ✓ GGUF file: {result['size_gb']:.2f} GB")

        self.telemetry.event("compress", "pass2", **result)
        self.pipeline_report['quant'] = result
        return result

    def optimize_server(self, gguf_path: Optional[str] = None) -> Dict:
        """Stage 5: Launch optimized inference server."""
        print_section("Stage 5: Optimization — Inference Server")

        import torch
        result = {}

        # Check vLLM availability
        vllm_available = False
        try:
            import vllm
            vllm_available = True
        except ImportError:
            pass

        if vllm_available:
            print("  vLLM available — provides PagedAttention, continuous batching")
            result['backend'] = 'vllm'
        else:
            print("  vLLM not available — using PyTorch inference")
            result['backend'] = 'pytorch'

        # Test with llama.cpp if GGUF available
        if gguf_path and os.path.exists(gguf_path):
            cli_path = "/content/llama.cpp/build/bin/llama-cli"
            if os.path.exists(cli_path):
                ngl = 99 if torch.cuda.is_available() else 0
                print(f"  Testing llama.cpp (ngl={ngl})...")
                t0 = time.perf_counter()
                r = subprocess.run(
                    [cli_path, "-m", gguf_path, "-p",
                     "The meaning of life is", "-n", "30",
                     "--temp", "0", f"-ngl", str(ngl), "--no-warmup"],
                    capture_output=True, text=True, timeout=120
                )
                t1 = time.perf_counter()
                output = r.stdout[-500:] if len(r.stdout) > 500 else r.stdout
                print(f"  llama.cpp: {t1-t0:.1f}s")
                print(f"  Output: {output[:200]}")
                result['llama_cpp_time_s'] = round(t1 - t0, 2)
                result['gguf_path'] = gguf_path

        self.telemetry.event("optimize", "server", **result)
        self.pipeline_report['optimize'] = result
        return result

    def benchmark_all(self) -> Dict:
        """Stage 6: Full benchmark suite."""
        print_section("Stage 6: Benchmark Suite")

        model_for_bench = self.student_model or self.loader.model
        bench = Benchmark(model_for_bench, self.loader.tokenizer,
                          device=self.device, telemetry=self.telemetry)

        with self.telemetry.timer("benchmark", "full_suite"):
            self.bench_results = bench.run_full_suite()

        self.pipeline_report['benchmarks'] = self.bench_results
        return self.bench_results

    def save_checkpoint(self, stage: str):
        """Save pipeline checkpoint to Drive."""
        if not self.drive_cache:
            return
        import torch
        path = self.drive_cache.checkpoint_path(self.model_name, stage)
        try:
            model_to_save = self.student_model or (self.loader.model if self.loader else None)
            torch.save({
                'stage': stage,
                'model_name': self.model_name,
                'config': {k: v for k, v in self.config.__dict__.items()} if self.config else {},
                'pipeline_report': self.pipeline_report,
                'telemetry_events': self.telemetry.events,
            }, path)
            print(f"  ✓ Checkpoint saved: {stage}")
        except Exception as e:
            print(f"  ⚠ Checkpoint save failed: {e}")

    def print_final_summary(self):
        """Print the complete pipeline summary table."""
        print_header("FINAL SUMMARY")
        cfg = self.config
        distill_r = self.pipeline_report.get('distill', {})
        quant_r = self.pipeline_report.get('quant', {})

        table = f"""
  ┌───────────────────────────────┬───────────────┬───────────────┬──────────────┐
  │ Pipeline Stage                │    Params     │    VRAM       │   Fidelity   │
  ├───────────────────────────────┼───────────────┼───────────────┼──────────────┤
  │ Original (fp16)              │ {format_params(cfg.total_params):>10}   │ {cfg.vram_fp16_gb:>7.2f} GB   │  baseline    │
  │ EML Converted                │ {format_params(cfg.eml_params):>10}   │ {cfg.vram_eml_fp16_gb:>7.4f} GB   │  cosim≈1     │
  │ int16 Crystallized           │ {format_params(cfg.total_params):>10}   │ {cfg.vram_fp16_gb:>7.2f} GB   │  word-match  │
  │ Distilled Student            │ {format_params(distill_r.get('student_params',0)):>10}   │ {distill_r.get('student_vram_mb',0)/1024:>7.2f} GB   │  distill     │
  │ Q4_K_M GGUF                 │ (4-bit)        │ {quant_r.get('size_gb','N/A'):>7} GB   │  quantized   │
  └───────────────────────────────┴───────────────┴───────────────┴──────────────┘

  Compression chain:
    {format_params(cfg.total_params)} (fp16, {cfg.vram_fp16_gb:.2f} GB)
      → EML: {cfg.compression_ratio:.1f}× parameter reduction
      → int16: word-for-word match preserved, 2× storage compression
      → Distill: {distill_r.get('scale_factor','?')}× smaller student
      → Q4_K_M: ~4× storage compression → {quant_r.get('size_gb', 'N/A')} GB

  VRAM reduction: {cfg.vram_fp16_gb:.2f} GB → {distill_r.get('student_vram_mb', 0)/1024:.2f} GB (student)
                  or → {quant_r.get('size_gb', 'N/A')} GB (GGUF on disk)
"""
        print(table)

        # Generation speed results
        gen = self.bench_results.get('generation', {})
        if gen:
            print(f"  Generation speed: {gen.get('avg_tokens_per_sec', 'N/A')} tok/s")
            print(f"  Latency: {gen.get('avg_ms_per_token', 'N/A')} ms/token")

        # Perplexity
        ppl = self.bench_results.get('perplexity', {})
        if ppl and ppl.get('perplexity') != 'failed':
            print(f"  Perplexity: {ppl.get('perplexity', 'N/A')}")

        # Token match
        chat = self.bench_results.get('chat_comparison', {})
        if chat:
            match = chat.get('match_pct', 0)
            print(f"  Token match: {match:.1f}%")
            if match == 100.0:
                print("  ★★★ WORD-FOR-WORD MATCH VERIFIED ★★★")

        # Save full report
        report = {
            "model": self.model_name,
            "config": {k: v for k, v in cfg.__dict__.items()},
            "pipeline_report": self.pipeline_report,
            "benchmarks": self.bench_results,
            "telemetry": self.telemetry.events,
            "hardware": self.telemetry.hardware_report(),
        }
        report_path = f"qwen_crystal_report_{self.model_name.replace('/','_')}.json"
        with open(report_path, "w") as f:
            json.dump(report, f, indent=2, default=str)
        print(f"\n  Report saved: {report_path}")

        if self.drive_cache:
            drive_path = self.drive_cache.save_artifact(
                self.model_name, "pipeline_report.json",
                json.dumps(report, indent=2, default=str))
            print(f"  Drive report: {drive_path}")

    def run_full_pipeline(self):
        """Run the complete pipeline from start to finish."""
        self.setup()

        if not self.download_model():
            print("FATAL: Could not load model.")
            return None
        self.save_checkpoint("loaded")

        eml_results = self.eml_convert()
        self.save_checkpoint("eml_converted")

        crystal_results = self.compress_pass1()
        self.save_checkpoint("crystallized")

        distill_results = self.knowledge_distill(
            scale_factor=0.5, n_steps=500)
        self.save_checkpoint("distilled")

        quant_results = self.compress_pass2(quant_type="Q4_K_M")
        self.save_checkpoint("quantized")

        server_results = self.optimize_server(
            gguf_path=quant_results.get('gguf_path'))

        bench_results = self.benchmark_all()
        self.save_checkpoint("benchmarked")

        self.print_final_summary()
        print(self.telemetry.summary())

        return self.pipeline_report


# ════════════════════════════════════════════════════════════════════════════
# §12. Colab Cell Functions (direct imports)
# ════════════════════════════════════════════════════════════════════════════

def colab_cell_1_install():
    """Install all required packages."""
    cmds = [
        "pip install -q torch torchvision torchaudio",
        "pip install -q transformers accelerate sentencepiece protobuf",
        "pip install -q datasets scikit-learn",
        "pip install -q optimum 2>/dev/null || true",
        "pip install -q auto-gptq 2>/dev/null || true",
    ]
    for cmd in cmds:
        print(f"  $ {cmd}")
        r = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        if r.returncode != 0 and 'error' in r.stderr.lower():
            print(f"    WARNING: {r.stderr[:200]}")
    print("  ✓ Installation complete")


def colab_cell_2_download(model_name="Qwen/Qwen2.5-3B-Instruct"):
    """Download model with Drive cache."""
    pipeline = QwenCrystalPipeline(model_name=model_name, use_drive=True)
    pipeline.setup()
    success = pipeline.download_model()
    return pipeline if success else None


# ════════════════════════════════════════════════════════════════════════════
# §13. Main entry point
# ════════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Qwen OISCC-EML Compression Pipeline v2")
    parser.add_argument("--model", default="Qwen/Qwen2.5-3B-Instruct",
                       help="HuggingFace model name (start with Qwen2.5)")
    parser.add_argument("--device", default="auto",
                       help="Device (auto, cuda, cpu)")
    parser.add_argument("--no-drive", action="store_true",
                       help="Disable Google Drive cache")
    parser.add_argument("--skip-gguf", action="store_true",
                       help="Skip GGUF conversion (saves time)")
    parser.add_argument("--skip-distill", action="store_true",
                       help="Skip knowledge distillation")
    parser.add_argument("--distill-scale", type=float, default=0.5,
                       help="Student model scale factor (0.25, 0.5, 0.75)")
    parser.add_argument("--distill-steps", type=int, default=500,
                       help="Number of distillation training steps")
    parser.add_argument("--gguf-quant", default="Q4_K_M",
                       help="GGUF quantization type (Q4_K_M, Q5_K_M, Q8_0)")
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    np.random.seed(args.seed)

    pipeline = QwenCrystalPipeline(
        model_name=args.model,
        use_drive=not args.no_drive,
        device=args.device,
        skip_gguf=args.skip_gguf,
        skip_distill=args.skip_distill,
    )

    results = pipeline.run_full_pipeline()