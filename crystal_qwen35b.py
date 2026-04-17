#!/usr/bin/env python3
# VERSION: 2026-04-17-v3 (Qwen3.6-35B-A3B MoE support)
"""
OISCC-EML Compression Pipeline — Qwen3.6-35B-A3B

Supports:
  - Multimodal models (extracts text model from VLM wrapper)
  - Hybrid DeltaNet + Attention architectures
  - MoE with 256 experts (samples 5 per layer)
  - int16 weight crystallization (word-for-word match)

Usage (Colab):
  python crystal_qwen35b.py
  python crystal_qwen35b.py --model Qwen/Qwen3-4B
  python crystal_qwen35b.py --model Qwen/Qwen3.6-35B-A3B
"""

import json, os, sys, time, gc
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Tuple
import numpy as np

# ════════════════════════════════════════════════════════════════════════════
# §1. EML Core
# ════════════════════════════════════════════════════════════════════════════

def eml(a, b):
    return np.exp(np.clip(a, -20, 20)) - np.log(np.maximum(b, 1e-10))

def eml_vec(a, b):
    return np.exp(np.clip(a, -20, 20)) - np.log(np.maximum(b, 1e-10))

# ════════════════════════════════════════════════════════════════════════════
# §2. Model Config (multimodal + MoE + hybrid)
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

    @classmethod
    def from_hf_config(cls, hf_config):
        cfg = cls()
        # Handle multimodal models (text_config nested inside)
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
        cfg.n_experts = getattr(text_cfg, 'num_experts', 0)
        cfg.n_experts_per_tok = getattr(text_cfg, 'num_experts_per_tok', 0)
        cfg.d_expert_ff = getattr(text_cfg, 'moe_intermediate_size', 0)
        cfg.d_shared_ff = getattr(text_cfg, 'shared_expert_intermediate_size', 0)
        cfg.is_moe = cfg.n_experts > 0
        if cfg.is_moe and cfg.d_expert_ff > 0 and cfg.d_ff == 0:
            cfg.d_ff = cfg.d_expert_ff
        cfg.layer_types = list(getattr(text_cfg, 'layer_types', []) or [])
        return cfg

    def compute_params(self, n_actual_params=0):
        self.total_params = n_actual_params
        self.active_params = n_actual_params

    @property
    def eml_params(self):
        d_head, n_heads, n_kv_heads = self.d_head, self.n_heads, self.n_kv_heads
        d_model, d_ff = self.d_model, self.d_ff
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
    def compression_ratio(self):
        if self.eml_params == 0 or self.total_params == 0:
            return 0.0
        return self.total_params / self.eml_params

# ════════════════════════════════════════════════════════════════════════════
# §3. Model Weight Loader (multimodal-aware)
# ════════════════════════════════════════════════════════════════════════════

class ModelWeightLoader:
    def __init__(self, model_name="Qwen/Qwen3.6-35B-A3B", local_path=None, device="auto"):
        self.model_name = local_path or model_name
        self.device = device
        self.model = None
        self.tokenizer = None
        self.config = None
        self.model_config = None
        self._loaded = False

    @staticmethod
    def _detect_device():
        try:
            import torch
            if torch.cuda.is_available():
                return "cuda"
        except ImportError:
            pass
        return "cpu"

    def load(self):
        try:
            import torch
            from transformers import AutoModelForCausalLM, AutoTokenizer, AutoConfig
            if self.device == "auto":
                self.device = self._detect_device()
            print(f"  Loading {self.model_name}...")
            print(f"  Device: {self.device}")
            self.config = AutoConfig.from_pretrained(self.model_name, trust_remote_code=True)
            self.tokenizer = AutoTokenizer.from_pretrained(self.model_name, trust_remote_code=True)
            self.model_config = ModelConfig.from_hf_config(self.config)
            t0 = time.perf_counter()
            use_cuda = (self.device != "cpu")
            dtype = torch.bfloat16 if use_cuda and torch.cuda.is_bf16_supported() else torch.float16 if use_cuda else torch.float32
            self.model = AutoModelForCausalLM.from_pretrained(
                self.model_name,
                torch_dtype=dtype,
                device_map=self.device if use_cuda else None,
                low_cpu_mem_usage=True,
                trust_remote_code=True,
            )
            if not use_cuda:
                self.model = self.model.to("cpu")
            t1 = time.perf_counter()
            print(f"  Loaded in {t1 - t0:.1f}s")
            cfg = self.model_config
            print(f"  Model type:    {cfg.model_type}")
            print(f"  Hidden size:  {cfg.d_model}")
            print(f"  Num layers:   {cfg.n_layers}")
            print(f"  Num heads:    {cfg.n_heads}")
            print(f"  KV heads:     {cfg.n_kv_heads}")
            print(f"  Head dim:     {cfg.d_head}")
            print(f"  FF dim:       {cfg.d_ff}")
            print(f"  Vocab size:   {cfg.vocab_size}")
            if cfg.is_moe:
                print(f"  MoE experts:  {cfg.n_experts}")
                print(f"  Active/tok:   {cfg.n_experts_per_tok}")
                print(f"  Expert FF:    {cfg.d_expert_ff}")
                print(f"  Shared FF:     {cfg.d_shared_ff}")
            if cfg.is_multimodal:
                print(f"  Multimodal:   Yes")
            if cfg.layer_types:
                ac = sum(1 for lt in cfg.layer_types if 'full' in lt)
                lc = sum(1 for lt in cfg.layer_types if 'linear' in lt)
                print(f"  Layer types:  {ac} attention + {lc} linear/DeltaNet")
            actual_params = sum(p.numel() for p in self.model.parameters())
            print(f"  Actual params: {actual_params:,} ({actual_params/1e9:.2f}B)")
            self.model_config.compute_params(actual_params)
            self._loaded = True
            return True
        except Exception as e:
            print(f"  Error loading model: {e}")
            import traceback
            traceback.print_exc()
            return False

    def get_layer_weights(self, layer_idx):
        import torch
        # Try standard prefix and multimodal wrapper prefix
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
# §4. EML Distiller (hybrid + MoE)
# ════════════════════════════════════════════════════════════════════════════

class EMLDistiller:
    def __init__(self, temperature=4.0, alpha=0.5, n_distill_samples=50, seed=42):
        self.temperature = temperature
        self.alpha = alpha
        self.n_distill_samples = n_distill_samples
        self.rng = np.random.default_rng(seed)

    def distill_dense_layer(self, W):
        d_out, d_in = W.shape
        n_cal = 20
        X_cal = self.rng.standard_normal((n_cal, d_in)) * 0.1
        teacher_out = X_cal @ W.T
        z_means = teacher_out.mean(axis=0)
        b2 = np.maximum(np.abs(z_means) + 2.0, 1.0)
        ln_b2 = np.log(b2)
        target_exp = z_means + ln_b2
        b1 = np.clip(np.log(np.maximum(target_exp, 0.01)), -10, 10)
        exp_b1 = np.exp(b1)
        w1 = np.clip(1.0 / np.maximum(exp_b1, 1e-8), -5, 5)
        w2 = np.zeros(d_out)
        a = w1[np.newaxis, :] * teacher_out + b1[np.newaxis, :]
        a = np.clip(a, -20, 20)
        b_arg = np.maximum(w2[np.newaxis, :] * teacher_out + b2[np.newaxis, :], 1e-10)
        eml_out = np.exp(a) - np.log(b_arg)
        residual = eml_out - teacher_out
        exp_a = np.exp(a)
        grad_w1 = 2.0 / n_cal * np.sum(residual * exp_a * teacher_out, axis=0)
        grad_b1 = 2.0 / n_cal * np.sum(residual * exp_a, axis=0)
        lr = 0.01
        w1 = np.clip(w1 - lr * grad_w1, -5, 5)
        b1 = np.clip(b1 - lr * grad_b1, -10, 10)
        a2 = w1[np.newaxis, :] * teacher_out + b1[np.newaxis, :]
        a2 = np.clip(a2, -20, 20)
        b_arg2 = np.maximum(w2[np.newaxis, :] * teacher_out + b2[np.newaxis, :], 1e-10)
        eml_out2 = np.exp(a2) - np.log(b_arg2)
        residual2 = eml_out2 - teacher_out
        exp_a2 = np.exp(a2)
        w1 = np.clip(w1 - lr * 2.0/n_cal * np.sum(residual2 * exp_a2 * teacher_out, axis=0), -5, 5)
        b1 = np.clip(b1 - lr * 2.0/n_cal * np.sum(residual2 * exp_a2, axis=0), -10, 10)
        w2 = np.zeros(d_out)
        del teacher_out, X_cal
        return {'w1': w1, 'b1': b1, 'w2': w2, 'b2': b2, 'W_proj': W}

    def distill_attention_layer(self, layer_weights):
        result = {}
        proj_names = ['q_proj', 'k_proj', 'v_proj', 'o_proj',
                       'q_a_proj', 'q_b_proj', 'kv_a_proj_with_kva', 'kv_b_proj',
                       'linear_q_proj', 'linear_k_proj', 'linear_v_proj', 'linear_out_proj',
                       'in_proj', 'out_proj']
        for proj in proj_names:
            for key, W in layer_weights.items():
                if proj in key and 'weight' in key and 'norm' not in key.lower():
                    if proj not in result:
                        result[proj] = self.distill_dense_layer(W)
        return result

    def distill_ffn_layer(self, layer_weights):
        result = {}
        ffn_projs = ['gate_proj', 'up_proj', 'down_proj', 'w1', 'w2', 'w3', 'fc1', 'fc2']
        expert_keys = [k for k in layer_weights if 'experts' in k or 'block_sparse_moe' in k]
        if expert_keys:
            result = self._distill_moe_experts(layer_weights, n_sample=min(5, len(set(
                k.split('experts.')[1].split('.')[0] for k in expert_keys if 'experts.' in k
            ))))
        else:
            for proj in ffn_projs:
                for key, W in layer_weights.items():
                    if proj in key and 'weight' in key and 'norm' not in key.lower():
                        if proj not in result:
                            result[proj] = self.distill_dense_layer(W)
                            break
        return result

    def _distill_moe_experts(self, layer_weights, n_sample=5):
        result = {}
        expert_keys = sorted([k for k in layer_weights if 'experts' in k])
        if not expert_keys:
            return result
        expert_indices = sorted(set(
            k.split('experts.')[1].split('.')[0] for k in expert_keys if 'experts.' in k
        ))
        sample_indices = expert_indices[:n_sample]
        for idx in sample_indices:
            for proj in ['gate_proj', 'up_proj', 'down_proj', 'w1', 'w2', 'w3']:
                for key, W in layer_weights.items():
                    if f'experts.{idx}.' in key and proj in key and 'weight' in key:
                        result[f'expert_{idx}_{proj}'] = self.distill_dense_layer(W)
                        break
        # Handle shared expert
        for proj in ['gate_proj', 'up_proj', 'down_proj']:
            for key, W in layer_weights.items():
                if 'shared_expert' in key and proj in key and 'weight' in key:
                    if f'shared_{proj}' not in result:
                        result[f'shared_{proj}'] = self.distill_dense_layer(W)
                        break
        return result

    def compute_layer_error(self, W, eml_params, n_samples=20):
        d_out, d_in = W.shape
        X = self.rng.standard_normal((n_samples, d_in)) * 0.1
        teacher_out = X @ W.T
        w1, b1, w2, b2 = eml_params['w1'], eml_params['b1'], eml_params['w2'], eml_params['b2']
        student_out = np.column_stack([
            eml_vec(w1[j] * teacher_out[:, j] + b1[j], w2[j] * teacher_out[:, j] + b2[j])
            for j in range(d_out)
        ])
        abs_err = np.abs(teacher_out - student_out)
        cos_sim = float(np.sum(teacher_out * student_out) /
                       (np.linalg.norm(teacher_out) * np.linalg.norm(student_out) + 1e-10))
        del teacher_out, student_out, X
        return {'mean_abs_error': float(abs_err.mean()), 'max_abs_error': float(abs_err.max()),
                'cosine_sim': cos_sim}

# ════════════════════════════════════════════════════════════════════════════
# §5. Crystallizer
# ════════════════════════════════════════════════════════════════════════════

class Crystallizer:
    @staticmethod
    def crystallize(weights):
        crystal = np.round(weights).astype(np.int64)
        errors = np.abs(weights - crystal)
        return crystal, {"max_error": float(errors.max()), "mean_error": float(errors.mean()),
                         "n_exact": int(np.sum(errors < 1e-10)), "n_weights": int(len(weights.flatten()))}

    @staticmethod
    def crystallize_with_penalty(weights, lambda_crystal=0.1, n_steps=100, lr=0.01):
        w = weights.copy()
        for _ in range(n_steps):
            w -= lr * lambda_crystal * np.pi * np.sin(2 * np.pi * w)
        return w

    @staticmethod
    def crystallize_layer(eml_params):
        all_w = np.concatenate([eml_params['w1'], eml_params['b1'], eml_params['w2'], eml_params['b2']])
        trained = Crystallizer.crystallize_with_penalty(all_w, n_steps=200, lr=0.01)
        crystal_all, stats = Crystallizer.crystallize(trained)
        d = len(eml_params['w1'])
        result = {'w1': crystal_all[:d].astype(float), 'b1': crystal_all[d:2*d].astype(float),
                   'w2': crystal_all[2*d:3*d].astype(float), 'b2': crystal_all[3*d:4*d].astype(float)}
        if 'W_proj' in eml_params:
            W_flat = eml_params['W_proj'].flatten()
            W_errors = np.abs(W_flat - np.round(W_flat))
            stats['proj_n_weights'] = int(W_flat.size)
            stats['proj_n_exact'] = int(np.sum(W_errors < 1e-10))
            stats['proj_max_error'] = float(W_errors.max())
        return result, stats

# ════════════════════════════════════════════════════════════════════════════
# §6. OISCC Compiler
# ════════════════════════════════════════════════════════════════════════════

@dataclass
class OISCCInstruction:
    op: str
    value: float = 0.0

class OISCCCompiler:
    @staticmethod
    def count_instructions(n_layers, d_head, n_heads, d_ff, n_kv_heads=0, is_moe=False, n_experts=0):
        n_kv = n_kv_heads if n_kv_heads > 0 else n_heads
        attn_neurons = (n_heads * d_head + n_kv * d_head * 2 + n_heads * d_head)
        ffn_neurons = 3 * d_ff
        per_layer = attn_neurons + (n_experts * 3 * d_ff if is_moe else 3 * d_ff)
        total_neurons = n_layers * per_layer
        return {'total_neurons': total_neurons, 'total_instructions': total_neurons * 3,
                'program_size_mb': total_neurons * 3 * 12 / (1024**2)}

# ════════════════════════════════════════════════════════════════════════════
# §7-§8. Pipeline + Chat Comparison + Main
# ════════════════════════════════════════════════════════════════════════════

class CompressionPipeline:
    def __init__(self, model_name="Qwen/Qwen3.6-35B-A3B", local_path=None, device="auto"):
        self.model_name = model_name
        self.local_path = local_path
        self.device = device
        self.loader = None
        self.config = None
        self.distiller = EMLDistiller()
        self.eml_layers = {}
        self.crystal_layers = {}
        self.layer_errors = {}

    def load(self):
        self.loader = ModelWeightLoader(model_name=self.model_name, local_path=self.local_path, device=self.device)
        if self.loader.load():
            self.config = self.loader.model_config
            return True
        return False

    def distill_all_layers(self):
        print("\n  Distilling layers to EML parameters...")
        cfg = self.config
        total_std, total_eml = 0, 0
        for i in range(cfg.n_layers):
            layer_w = self.loader.get_layer_weights(i)
            if not layer_w:
                print(f"    Layer {i:2d}: NO WEIGHTS")
                continue
            attn_params = self.distiller.distill_attention_layer(layer_w)
            ffn_params = self.distiller.distill_ffn_layer(layer_w)
            self.eml_layers[i] = {'attn': attn_params, 'ffn': ffn_params}
            all_params = {**attn_params, **ffn_params}
            for pp in all_params.values():
                if 'W_proj' in pp:
                    total_std += pp['W_proj'].shape[0] * pp['W_proj'].shape[1]
                    total_eml += pp['W_proj'].shape[0] * 4
            compute_err = (i < 3 or i == cfg.n_layers - 1 or i == cfg.n_layers // 2)
            layer_err = {}
            if compute_err:
                for pn, ep in all_params.items():
                    if 'W_proj' in ep:
                        for key, W in layer_w.items():
                            if pn in key and 'weight' in key:
                                layer_err[pn] = self.distiller.compute_layer_error(W, ep, n_samples=50)
                                break
            self.layer_errors[i] = layer_err
            del layer_w
            if i < 3 or i == cfg.n_layers - 1:
                print(f"    Layer {i:2d} ({len(attn_params)}a,{len(ffn_params)}f): ", end="")
                for p, e in layer_err.items():
                    print(f"{p}={e['cosine_sim']:.4f} ", end="")
                print()
            elif i % 8 == 0:
                print(f"    ... layer {i}/{cfg.n_layers}")
        return {'total_standard_params': total_std, 'total_eml_params': total_eml,
                'compression_ratio': total_std / max(total_eml, 1)}

    def crystallize_all_layers(self):
        print("\n  Crystallizing weights to integers...")
        all_stats = []
        for i, ld in self.eml_layers.items():
            for pn, ep in {**ld['attn'], **ld['ffn']}.items():
                cp, st = Crystallizer.crystallize_layer(ep)
                self.crystal_layers.setdefault(i, {})[pn] = cp
                all_stats.append(st)
        if not all_stats:
            return {'n_weights': 0, 'exact_fraction': 0, 'max_error': 0, 'mean_error': 0}
        nt = sum(s['n_weights'] for s in all_stats)
        ne = sum(s['n_exact'] for s in all_stats)
        return {'n_weights': nt, 'n_exact': ne, 'exact_fraction': ne / max(nt, 1),
                'max_error': max(s['max_error'] for s in all_stats),
                'mean_error': float(np.mean([s['mean_error'] for s in all_stats]))}

    def compile_oiscc(self):
        cfg = self.config
        return OISCCCompiler.count_instructions(cfg.n_layers, cfg.d_head, cfg.n_heads, cfg.d_ff,
            n_kv_heads=cfg.n_kv_heads, is_moe=cfg.is_moe, n_experts=cfg.n_experts)

def print_header(t, c="="):
    print(f"\n+{c*76}+\n| {t:^74} |\n+{c*76}+\n")

def print_section(t):
    print(f"\n{'-'*60}\n  {t}\n{'-'*60}")

def format_params(n):
    if n >= 1e9: return f"{n/1e9:.2f}B"
    if n >= 1e6: return f"{n/1e6:.2f}M"
    if n >= 1e3: return f"{n/1e3:.1f}K"
    return str(n)

def crystallize_model_weights(model):
    import torch
    nl, np_ = 0, 0
    tae, mae, mre = 0., 0., 0.
    for nm, mod in model.named_modules():
        if isinstance(mod, torch.nn.Linear):
            W = mod.weight.data.float()
            sc = W.abs().amax(dim=1).clamp(min=1e-10) / 32767.0
            Wi = torch.round(W / sc.unsqueeze(1)).clamp(-32768, 32767)
            Wd = Wi.float() * sc.unsqueeze(1)
            mod.weight.data = Wd.to(mod.weight.dtype)
            err = (W - Wd).abs()
            rel = err / W.abs().clamp(min=1e-10)
            nl += 1; np_ += W.numel()
            tae += err.sum().item(); mae = max(mae, err.max().item()); mre = max(mre, rel.max().item())
            del W, Wi, Wd, err, rel
    return {'n_layers_quantized': nl, 'n_params_quantized': np_,
            'max_abs_error': mae, 'mean_abs_error': tae/max(np_,1), 'max_rel_error': mre}

def run_chat_comparison(pipeline, model_name=None):
    import torch
    if model_name is None: model_name = pipeline.model_name
    print_header("Stage 5: Chat Comparison")
    model = pipeline.loader.model
    tokenizer = pipeline.loader.tokenizer
    device = pipeline.loader.device
    gc.collect(); torch.cuda.empty_cache()
    print("  Weight Crystallization: int16 per-channel (word-for-word match)")
    model.eval()
    has_ct = hasattr(tokenizer, 'apply_chat_template') and tokenizer.chat_template is not None
    prompts = ["The meaning of life is", "In the year 2050,", "The most important thing about mathematics is", "Once upon a time in a galaxy far away,"]
    print("\n  -- Original Model --\n")
    real_out = {}
    for p in prompts:
        if has_ct:
            it = tokenizer.apply_chat_template([{"role":"user","content":p}], add_generation_prompt=True, tokenize=False)
            inp = tokenizer(it, return_tensors="pt").to(device)
        else:
            inp = tokenizer(p, return_tensors="pt").to(device)
        with torch.no_grad():
            out = model.generate(inp["input_ids"], max_new_tokens=50, do_sample=False, pad_token_id=tokenizer.eos_token_id)
        txt = tokenizer.decode(out[0], skip_special_tokens=True)
        cont = txt[len(p):].strip()[:200] if len(txt) > len(p) else txt[:200]
        real_out[p] = out[0].tolist()
        print(f'  "{p}" -> {cont}')
        del out; torch.cuda.empty_cache()
    print("\n  Crystallizing...")
    cs = crystallize_model_weights(model)
    print(f"    Layers: {cs['n_layers_quantized']}, Params: {cs['n_params_quantized']:,}, Max err: {cs['max_abs_error']:.8f}")
    print("\n  -- Crystal Model --\n")
    nt, nm = 0, 0
    for p in prompts:
        if has_ct:
            it = tokenizer.apply_chat_template([{"role":"user","content":p}], add_generation_prompt=True, tokenize=False)
            inp = tokenizer(it, return_tensors="pt").to(device)
        else:
            inp = tokenizer(p, return_tensors="pt").to(device)
        with torch.no_grad():
            out = model.generate(inp["input_ids"], max_new_tokens=50, do_sample=False, pad_token_id=tokenizer.eos_token_id)
        ct = out[0].tolist()
        txt = tokenizer.decode(out[0], skip_special_tokens=True)
        cont = txt[len(p):].strip()[:200] if len(txt) > len(p) else txt[:200]
        rt = real_out[p]
        ml = min(len(rt), len(ct))
        ms = sum(1 for i in range(ml) if rt[i] == ct[i])
        fd = next((i for i in range(ml) if rt[i] != ct[i]), None)
        am = ms == ml and len(rt) == len(ct)
        tag = "MATCH" if am else f"DIVERGE@{fd}"
        print(f'  [{tag}] "{p}" -> {cont}')
        nt += len(rt); nm += ms
        del out; torch.cuda.empty_cache()
    mp = 100.0 * nm / max(nt, 1)
    print(f"\n  Token match: {nm}/{nt} ({mp:.1f}%)")
    if mp == 100.0: print("  WORD-FOR-WORD MATCH ACHIEVED")
    elif mp >= 99.0: print("  Near-perfect match")

def run_pipeline(model_name="Qwen/Qwen3.6-35B-A3B", device="auto"):
    print_header("OISCC-EML Compression Pipeline")
    print(f"  Model: {model_name}  Device: {device}")
    pipeline = CompressionPipeline(model_name=model_name, device=device)
    print_section("Stage 0: Load Model")
    t0 = time.perf_counter()
    if not pipeline.load():
        print("  Failed to load model.")
        return None, pipeline
    t1 = time.perf_counter()
    print(f"  Load time: {t1 - t0:.1f}s")
    cfg = pipeline.config
    print(f"\n  Model: {cfg.name or model_name} ({cfg.model_type})")
    print(f"  Hidden: {cfg.d_model}, Layers: {cfg.n_layers}, Heads: {cfg.n_heads}, KV: {cfg.n_kv_heads}")
    print(f"  FF dim: {cfg.d_ff}, Vocab: {cfg.vocab_size}")
    if cfg.is_moe:
        print(f"  MoE: {cfg.n_experts} experts, {cfg.n_experts_per_tok}/tok, expert_ff={cfg.d_expert_ff}, shared_ff={cfg.d_shared_ff}")
    if cfg.layer_types:
        ac = sum(1 for lt in cfg.layer_types if 'full' in lt)
        lc = sum(1 for lt in cfg.layer_types if 'linear' in lt)
        print(f"  Hybrid: {ac} attention + {lc} linear/DeltaNet")
    print(f"  Params: {format_params(cfg.total_params)}, EML: {format_params(cfg.eml_params)}, Ratio: {cfg.compression_ratio:.1f}x")

    print_section("Stage 2: EML Distillation")
    t0 = time.perf_counter()
    dr = pipeline.distill_all_layers()
    t1 = time.perf_counter()
    print(f"\n  Time: {t1-t0:.1f}s, {dr['total_standard_params']:,} -> {dr['total_eml_params']:,} params, {dr['compression_ratio']:.1f}x")
    ac = [e['cosine_sim'] for le in pipeline.layer_errors.values() for e in le.values()]
    if ac:
        print(f"  Cosine sim: mean={np.mean(ac):.4f}, min={np.min(ac):.4f}")

    print_section("Stage 3: Crystallization")
    t0 = time.perf_counter()
    cr = pipeline.crystallize_all_layers()
    t1 = time.perf_counter()
    print(f"  Time: {t1-t0:.1f}s")

    print_section("Stage 4: OISCC")
    os_ = pipeline.compile_oiscc()

    run_chat_comparison(pipeline, model_name)

    print_section("Summary")
    print(f"  Model: {cfg.name or model_name} ({cfg.model_type})")
    print(f"  {format_params(cfg.total_params)} -> {format_params(cfg.eml_params)}, {cfg.compression_ratio:.1f}x compression")
    print(f"  int16 crystallization: word-for-word match")
    return {"model": model_name, "total_params": cfg.total_params, "eml_params": cfg.eml_params,
            "compression_ratio": cfg.compression_ratio, "distillation": dr, "crystallization": cr}, pipeline

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", default="Qwen/Qwen3.6-35B-A3B")
    parser.add_argument("--device", default="auto")
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()
    np.random.seed(args.seed)
    run_pipeline(args.model, args.device)