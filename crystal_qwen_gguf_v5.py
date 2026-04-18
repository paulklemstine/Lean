#!/usr/bin/env python3
"""Crystal Qwen3.6-35B-A3B: GGUF v5 writer with ALL fixes.
- F32 for 1D tensors (fixes ggml f32*f16 MUL crash)
- No +1.0 on norm weights (llama.cpp handles RMSNorm internally)
- ssm_dt.bias (not .weight)
- 3D expert tensors
- attention.key_length=256, attention.value_length=256
- ffn_gate_inp_shexp as 1D
- n_kv=31
"""
import struct, os, time, gc, shutil
import numpy as np
import torch
from transformers import AutoModelForCausalLM, AutoConfig, AutoTokenizer
import io

# ======== GGUF Constants ========
GGUF_MAGIC = 0x46554747
GGML_TYPE_F32 = 0
GGML_TYPE_F16 = 1
GGML_TYPE_Q8_0 = 8
GGUF_TYPE_UINT32 = 4
GGUF_TYPE_INT32 = 5
GGUF_TYPE_FLOAT32 = 6
GGUF_TYPE_STRING = 8
GGUF_TYPE_ARRAY = 9
ALIGN = 32
ARCH = "qwen35moe"
GGUF_PATH = "/content/crystal-qwen3.6-35b-a3b-v5.gguf"

# ======== GGUF KV Helpers ========
def wkv_str(f, k, v):
    e = k.encode(); f.write(struct.pack('<Q', len(e))); f.write(e)
    f.write(struct.pack('<I', GGUF_TYPE_STRING))
    v2 = v.encode(); f.write(struct.pack('<Q', len(v2))); f.write(v2)

def wkv_u32(f, k, v):
    e = k.encode(); f.write(struct.pack('<Q', len(e))); f.write(e)
    f.write(struct.pack('<I', GGUF_TYPE_UINT32)); f.write(struct.pack('<I', v))

def wkv_f32(f, k, v):
    e = k.encode(); f.write(struct.pack('<Q', len(e))); f.write(e)
    f.write(struct.pack('<I', GGUF_TYPE_FLOAT32)); f.write(struct.pack('<f', v))

def wkv_arr_u32(f, k, vals):
    e = k.encode(); f.write(struct.pack('<Q', len(e))); f.write(e)
    f.write(struct.pack('<I', GGUF_TYPE_ARRAY))
    f.write(struct.pack('<I', GGUF_TYPE_UINT32)); f.write(struct.pack('<Q', len(vals)))
    for v in vals: f.write(struct.pack('<I', v))

def wkv_arr_str(f, k, vals):
    e = k.encode(); f.write(struct.pack('<Q', len(e))); f.write(e)
    f.write(struct.pack('<I', GGUF_TYPE_ARRAY))
    f.write(struct.pack('<I', GGUF_TYPE_STRING)); f.write(struct.pack('<Q', len(vals)))
    for v in vals:
        v2 = v.encode(); f.write(struct.pack('<Q', len(v2))); f.write(v2)

def wkv_arr_f32(f, k, vals):
    e = k.encode(); f.write(struct.pack('<Q', len(e))); f.write(e)
    f.write(struct.pack('<I', GGUF_TYPE_ARRAY))
    f.write(struct.pack('<I', GGUF_TYPE_FLOAT32)); f.write(struct.pack('<Q', len(vals)))
    for v in vals: f.write(struct.pack('<f', v))

def wkv_arr_i32(f, k, vals):
    e = k.encode(); f.write(struct.pack('<Q', len(e))); f.write(e)
    f.write(struct.pack('<I', GGUF_TYPE_ARRAY))
    f.write(struct.pack('<I', GGUF_TYPE_INT32)); f.write(struct.pack('<Q', len(vals)))
    for v in vals: f.write(struct.pack('<i', v))

# ======== Q8_0 Quantization ========
def quant_q8_0(arr):
    flat = arr.flatten().astype(np.float32)
    pad = (32 - len(flat) % 32) % 32
    if pad: flat = np.pad(flat, (0, pad))
    nb = len(flat) // 32
    blk = flat.reshape(nb, 32)
    amax = np.max(np.abs(blk), axis=1, keepdims=True)
    sc = (amax / 127.0).astype(np.float16)
    sf = np.where(sc.flatten() > 0, sc.flatten(), np.float16(1.0))
    q = np.round(blk / sf[:, np.newaxis]).clip(-127, 127).astype(np.int8)
    buf = bytearray(nb * 34)
    for i in range(nb):
        buf[i*34:i*34+2] = sc[i].tobytes()[:2]
        buf[i*34+2:i*34+34] = q[i].tobytes()
    return bytes(buf), nb * 34

# ======== Name Mapping ========
def map_param(nm, W):
    """Map HF param name + numpy array to list of (gguf_name, transformed_W, is_1d, layer_idx) or None"""
    if nm == 'model.embed_tokens.weight': return [('token_embd.weight', W, False, -1)]
    if nm == 'model.norm.weight': return [('output_norm.weight', W, True, -1)]  # 1D, NO +1.0
    if nm == 'lm_head.weight': return [('output.weight', W, False, -1)]
    if not nm.startswith('model.layers.'): return None
    parts = nm.split('.')
    li = int(parts[2])
    rest = '.'.join(parts[3:])

    # Norm weights: 1D, NO +1.0 (llama.cpp handles RMSNorm internally)
    if rest == 'input_layernorm.weight':
        return [('blk.{li}.attn_norm.weight', W, True, li)]
    if rest == 'post_attention_layernorm.weight':
        return [('blk.{li}.post_attention_norm.weight', W, True, li)]

    # Full attention projections (2D)
    if rest == 'self_attn.q_proj.weight': return [(f'blk.{li}.attn_q.weight', W, False, li)]
    if rest == 'self_attn.k_proj.weight': return [(f'blk.{li}.attn_k.weight', W, False, li)]
    if rest == 'self_attn.v_proj.weight': return [(f'blk.{li}.attn_v.weight', W, False, li)]
    if rest == 'self_attn.o_proj.weight': return [(f'blk.{li}.attn_output.weight', W, False, li)]

    # Attention norm weights (1D, NO +1.0)
    if rest == 'self_attn.q_norm.weight':
        return [(f'blk.{li}.attn_q_norm.weight', W, True, li)]
    if rest == 'self_attn.k_norm.weight':
        return [(f'blk.{li}.attn_k_norm.weight', W, True, li)]

    # Linear attention (SSM/DeltaNet)
    if rest == 'linear_attn.in_proj_qkv.weight':
        return [(f'blk.{li}.attn_qkv.weight', W, False, li)]
    if rest == 'linear_attn.in_proj_z.weight':
        return [(f'blk.{li}.attn_gate.weight', W, False, li)]
    if rest == 'linear_attn.in_proj_a.weight':
        return [(f'blk.{li}.ssm_alpha.weight', W, False, li)]
    if rest == 'linear_attn.in_proj_b.weight':
        return [(f'blk.{li}.ssm_beta.weight', W, False, li)]
    if rest == 'linear_attn.out_proj.weight':
        return [(f'blk.{li}.ssm_out.weight', W, False, li)]
    if rest == 'linear_attn.A_log':
        return [(f'blk.{li}.ssm_a', -np.exp(W), True, li)]  # neg_exp transform, 1D
    if rest == 'linear_attn.dt_bias':
        return [(f'blk.{li}.ssm_dt.bias', W.reshape(1, -1), True, li)]  # .bias NOT .weight
    # conv1d: HF shape [conv_channels, 1, d_conv] → squeeze → [conv_channels, d_conv]
    # GGUF expects ne=[d_conv, conv_channels]=[4, 8192]. Stored as 2D (not 1D!)
    if rest == 'linear_attn.conv1d.weight':
        return [(f'blk.{li}.ssm_conv1d.weight', W.squeeze(), False, li)]
    if rest == 'linear_attn.norm.weight':
        return [(f'blk.{li}.ssm_norm.weight', W, True, li)]  # 1D, NO +1.0

    # MoE gate
    if rest == 'mlp.gate.weight':
        return [(f'blk.{li}.ffn_gate_inp.weight', W, False, li)]

    # Shared expert gate (1D)
    if rest == 'mlp.shared_expert_gate.weight':
        return [(f'blk.{li}.ffn_gate_inp_shexp.weight', W.reshape(-1), True, li)]  # 1D

    # Shared expert projections
    if rest == 'mlp.shared_expert.gate_proj.weight':
        return [(f'blk.{li}.ffn_gate_shexp.weight', W, False, li)]
    if rest == 'mlp.shared_expert.up_proj.weight':
        return [(f'blk.{li}.ffn_up_shexp.weight', W, False, li)]
    if rest == 'mlp.shared_expert.down_proj.weight':
        return [(f'blk.{li}.ffn_down_shexp.weight', W, False, li)]

    # Expert tensors — keep as 3D
    if rest == 'mlp.experts.gate_up_proj':
        # W shape: [256, 1024, 2048] → split into gate [256,512,2048] + up [256,512,2048]
        W_gate = W[:, :512, :].reshape(256, 512, 2048)
        W_up = W[:, 512:, :].reshape(256, 512, 2048)
        return [
            (f'blk.{li}.ffn_gate_exps.weight', W_gate, False, li),
            (f'blk.{li}.ffn_up_exps.weight', W_up, False, li),
        ]
    if rest == 'mlp.experts.down_proj':
        # W shape: [256, 2048, 512] → keep 3D
        return [(f'blk.{li}.ffn_down_exps.weight', W.reshape(256, 2048, 512), False, li)]

    return None

# ======== Main Pipeline ========
def main():
    t_start = time.perf_counter()

    # 1. Load model
    print("Step 1: Loading model from HuggingFace...")
    model_name = "Qwen/Qwen3.6-35B-A3B"
    config = AutoConfig.from_pretrained(model_name, trust_remote_code=True)
    model = AutoModelForCausalLM.from_pretrained(
        model_name, config=config, torch_dtype=torch.bfloat16,
        device_map="auto", low_cpu_mem_usage=True, trust_remote_code=True
    )
    n_params = sum(p.numel() for p in model.parameters())
    print(f"  Loaded: {n_params/1e9:.2f}B params, VRAM: {torch.cuda.memory_allocated()/1e9:.1f} GB")

    # 2. Crystallize (int16 symmetric per-channel quantization)
    print("Step 2: Crystallizing weights (int16)...")
    n_cryst = 0
    max_err = 0.0
    for nm, param in model.named_parameters():
        if param.dim() >= 2:
            W = param.data.float()
            sc = W.abs().amax(dim=1, keepdim=True).clamp(min=1e-10) / 32767.0
            Wi = torch.round(W / sc).clamp(-32768, 32767)
            Wd = Wi.float() * sc
            err = (W - Wd).abs().max().item()
            max_err = max(max_err, err)
            param.data = Wd.to(param.dtype)
            n_cryst += W.numel()
        elif param.dim() == 1 and param.numel() > 1:
            W = param.data.float()
            sc = W.abs().max().clamp(min=1e-10) / 32767.0
            Wi = torch.round(W / sc).clamp(-32768, 32767)
            param.data = (Wi.float() * sc).to(param.dtype)
            n_cryst += W.numel()
    print(f"  Crystallized {n_cryst/1e9:.2f}B params, max error: {max_err:.8f}")

    # 3. Collect GGUF tensors
    print("Step 3: Collecting tensors...")
    gguf_tensors = []
    for nm, param in model.named_parameters():
        W = param.data.float().cpu().numpy()
        result = map_param(nm, W)
        if result is None:
            continue
        for name, arr, is_1d, li in result:
            gguf_tensors.append((name, arr, is_1d))
    gguf_tensors.sort(key=lambda x: x[0])
    n_tensors = len(gguf_tensors)
    print(f"  Total tensors: {n_tensors}")

    # 4. Compute types and sizes
    tensor_entries = []
    for name, W, is_1d in gguf_tensors:
        if is_1d and W.ndim >= 1:
            # 1D tensor — flatten to 1D, store as F32
            W_flat = W.flatten()
            ne_gguf = [len(W_flat)]
            n_el = len(W_flat)
            gtype = GGML_TYPE_F32
            nbytes = n_el * 4  # F32 = 4 bytes
        elif W.ndim == 2:
            ne_gguf = [W.shape[1], W.shape[0]]
            n_el = int(np.prod(ne_gguf))
            ne0 = ne_gguf[0]
            if ne0 < 32 or ne0 % 32 != 0:
                gtype = GGML_TYPE_F16
                nbytes = n_el * 2
            else:
                gtype = GGML_TYPE_Q8_0
                nbytes = ((n_el + 31) // 32) * 34
        elif W.ndim == 3:
            # 3D expert tensors: ne = [dim2, dim1, dim0] (ggml column-major)
            ne_gguf = [W.shape[2], W.shape[1], W.shape[0]]
            n_el = int(np.prod(ne_gguf))
            # For Q8_0, need ne[0] to be multiple of 32
            ne0 = ne_gguf[0]
            if ne0 < 32 or ne0 % 32 != 0:
                gtype = GGML_TYPE_F16
                nbytes = n_el * 2
            else:
                gtype = GGML_TYPE_Q8_0
                nbytes = ((n_el + 31) // 32) * 34
        else:
            raise ValueError(f"Unexpected ndim={W.ndim} for tensor {name}")

        tensor_entries.append({
            'name': name, 'ne': ne_gguf, 'gtype': gtype,
            'n_el': n_el, 'nbytes': nbytes, 'is_1d': is_1d
        })

    off = 0
    for t in tensor_entries:
        t['off'] = off
        off += t['nbytes']
        if off % ALIGN: off += ALIGN - (off % ALIGN)

    n_f32 = sum(1 for t in tensor_entries if t['gtype'] == GGML_TYPE_F32)
    n_f16 = sum(1 for t in tensor_entries if t['gtype'] == GGML_TYPE_F16)
    n_q8 = sum(1 for t in tensor_entries if t['gtype'] == GGML_TYPE_Q8_0)
    print(f"  F32: {n_f32}, F16: {n_f16}, Q8_0: {n_q8}")

    # 5. Load tokenizer
    print("Step 4: Loading tokenizer...")
    tokenizer = AutoTokenizer.from_pretrained(model_name, trust_remote_code=True)
    vocab = tokenizer.get_vocab()
    n_vocab = len(vocab)
    tokens_list = [""] * n_vocab
    scores_list = [-1.0] * n_vocab
    ttypes_list = [0] * n_vocab
    for token, idx in vocab.items():
        if idx < n_vocab:
            tokens_list[idx] = token
            scores_list[idx] = -1.0
            ttypes_list[idx] = 0
    for i in range(n_vocab):
        if tokens_list[i] == "":
            tokens_list[i] = f"<unused_{i}>"
            ttypes_list[i] = 4
    print(f"  Vocab: {n_vocab} tokens")

    # 6. Compute header (dry run)
    layer_types = [1 if 'Full' in model.model.layers[i].__class__.__name__ else 0 for i in range(40)]
    n_kv = 31  # Fixed count

    buf = io.BytesIO()
    buf.write(struct.pack('<I', GGUF_MAGIC)); buf.write(struct.pack('<I', 3))
    buf.write(struct.pack('<Q', n_tensors)); buf.write(struct.pack('<Q', n_kv))
    # Architecture KVs
    wkv_str(buf, "general.architecture", ARCH)
    wkv_str(buf, "general.name", "Crystal Qwen3.6-35B-A3B")
    wkv_u32(buf, f"{ARCH}.context_length", 262144)
    wkv_u32(buf, f"{ARCH}.embedding_length", 2048)
    wkv_u32(buf, f"{ARCH}.block_count", 40)
    wkv_u32(buf, f"{ARCH}.attention.head_count", 16)
    wkv_u32(buf, f"{ARCH}.attention.head_count_kv", 2)
    wkv_u32(buf, f"{ARCH}.attention.key_length", 256)     # v5: critical for head_dim=256
    wkv_u32(buf, f"{ARCH}.attention.value_length", 256)   # v5: critical for head_dim=256
    wkv_f32(buf, f"{ARCH}.attention.layer_norm_rms_epsilon", 1e-6)
    wkv_u32(buf, f"{ARCH}.rope.dimension_count", 32)
    wkv_f32(buf, f"{ARCH}.rope.freq_base", 10000000.0)
    wkv_arr_u32(buf, f"{ARCH}.rope.dimension_sections", [11, 11, 10, 0])
    wkv_u32(buf, f"{ARCH}.expert_count", 256)
    wkv_u32(buf, f"{ARCH}.expert_used_count", 8)
    wkv_u32(buf, f"{ARCH}.expert_feed_forward_length", 512)
    wkv_u32(buf, f"{ARCH}.expert_shared_feed_forward_length", 512)
    wkv_u32(buf, f"{ARCH}.ssm.conv_kernel", 4)
    wkv_u32(buf, f"{ARCH}.ssm.state_size", 128)
    wkv_u32(buf, f"{ARCH}.ssm.group_count", 16)
    wkv_u32(buf, f"{ARCH}.ssm.time_step_rank", 32)
    wkv_u32(buf, f"{ARCH}.ssm.inner_size", 4096)
    wkv_u32(buf, f"{ARCH}.full_attention_interval", 4)
    wkv_f32(buf, f"{ARCH}.attention.scale", 1.0/256.0)
    wkv_u32(buf, "tokenizer.ggml.eos_token_id", 248046)
    wkv_u32(buf, "tokenizer.ggml.padding_token_id", 248044)
    wkv_arr_u32(buf, f"{ARCH}.layer_types", layer_types)
    # Tokenizer KVs
    wkv_str(buf, "tokenizer.ggml.model", "llama")
    wkv_arr_str(buf, "tokenizer.ggml.tokens", tokens_list)
    wkv_arr_f32(buf, "tokenizer.ggml.scores", scores_list)
    wkv_arr_i32(buf, "tokenizer.ggml.token_type", ttypes_list)
    # Tensor info
    for t in tensor_entries:
        enc = t['name'].encode(); buf.write(struct.pack('<Q', len(enc))); buf.write(enc)
        buf.write(struct.pack('<I', len(t['ne'])))
        for d in t['ne']: buf.write(struct.pack('<Q', d))
        buf.write(struct.pack('<I', t['gtype']))
        buf.write(struct.pack('<Q', t['off']))
    pos = buf.tell()
    if pos % ALIGN: buf.write(b'\x00' * (ALIGN - pos % ALIGN))
    hdr_size = buf.tell()
    print(f"  Header: {hdr_size} bytes ({hdr_size/1e6:.1f} MB), n_kv={n_kv}")

    # 7. Write GGUF
    print("Step 5: Writing GGUF file...")
    t0 = time.perf_counter()

    # Clean HF cache to free space before writing
    hf_cache = os.path.expanduser("~/.cache/huggingface")
    if os.path.exists(hf_cache):
        shutil.rmtree(hf_cache)
        print("  Cleaned HF cache")

    # Free model from GPU to get more RAM for writing
    del model
    gc.collect()
    torch.cuda.empty_cache()
    print("  Freed model from GPU")

    # Reload just the tokenizer (already loaded above)
    # Re-read tensor data from the saved gguf_tensors list

    with open(GGUF_PATH, 'wb') as f:
        # Header
        f.write(struct.pack('<I', GGUF_MAGIC)); f.write(struct.pack('<I', 3))
        f.write(struct.pack('<Q', n_tensors)); f.write(struct.pack('<Q', n_kv))
        wkv_str(f, "general.architecture", ARCH)
        wkv_str(f, "general.name", "Crystal Qwen3.6-35B-A3B")
        wkv_u32(f, f"{ARCH}.context_length", 262144)
        wkv_u32(f, f"{ARCH}.embedding_length", 2048)
        wkv_u32(f, f"{ARCH}.block_count", 40)
        wkv_u32(f, f"{ARCH}.attention.head_count", 16)
        wkv_u32(f, f"{ARCH}.attention.head_count_kv", 2)
        wkv_u32(f, f"{ARCH}.attention.key_length", 256)
        wkv_u32(f, f"{ARCH}.attention.value_length", 256)
        wkv_f32(f, f"{ARCH}.attention.layer_norm_rms_epsilon", 1e-6)
        wkv_u32(f, f"{ARCH}.rope.dimension_count", 32)
        wkv_f32(f, f"{ARCH}.rope.freq_base", 10000000.0)
        wkv_arr_u32(f, f"{ARCH}.rope.dimension_sections", [11, 11, 10, 0])
        wkv_u32(f, f"{ARCH}.expert_count", 256)
        wkv_u32(f, f"{ARCH}.expert_used_count", 8)
        wkv_u32(f, f"{ARCH}.expert_feed_forward_length", 512)
        wkv_u32(f, f"{ARCH}.expert_shared_feed_forward_length", 512)
        wkv_u32(f, f"{ARCH}.ssm.conv_kernel", 4)
        wkv_u32(f, f"{ARCH}.ssm.state_size", 128)
        wkv_u32(f, f"{ARCH}.ssm.group_count", 16)
        wkv_u32(f, f"{ARCH}.ssm.time_step_rank", 32)
        wkv_u32(f, f"{ARCH}.ssm.inner_size", 4096)
        wkv_u32(f, f"{ARCH}.full_attention_interval", 4)
        wkv_f32(f, f"{ARCH}.attention.scale", 1.0/256.0)
        wkv_u32(f, "tokenizer.ggml.eos_token_id", 248046)
        wkv_u32(f, "tokenizer.ggml.padding_token_id", 248044)
        wkv_arr_u32(f, f"{ARCH}.layer_types", layer_types)
        wkv_str(f, "tokenizer.ggml.model", "llama")
        wkv_arr_str(f, "tokenizer.ggml.tokens", tokens_list)
        wkv_arr_f32(f, "tokenizer.ggml.scores", scores_list)
        wkv_arr_i32(f, "tokenizer.ggml.token_type", ttypes_list)

        # Tensor info
        for t in tensor_entries:
            enc = t['name'].encode(); f.write(struct.pack('<Q', len(enc))); f.write(enc)
            f.write(struct.pack('<I', len(t['ne'])))
            for d in t['ne']: f.write(struct.pack('<Q', d))
            f.write(struct.pack('<I', t['gtype']))
            f.write(struct.pack('<Q', t['off']))

        # Pad header
        pos = f.tell()
        if pos < hdr_size: f.write(b'\x00' * (hdr_size - pos))

        # Tensor data
        for idx, (name, W, is_1d) in enumerate(gguf_tensors):
            t = tensor_entries[idx]
            if t['gtype'] == GGML_TYPE_F32:
                # 1D tensors stored as F32
                f.write(W.flatten().astype(np.float32).tobytes())
            elif t['gtype'] == GGML_TYPE_F16:
                if W.ndim == 3:
                    f.write(W.flatten().astype(np.float16).tobytes())
                else:
                    f.write(W.astype(np.float16).tobytes())
            else:  # Q8_0
                if W.ndim == 3:
                    data, _ = quant_q8_0(W.flatten().reshape(-1))  # flatten 3D then quantize
                else:
                    data, _ = quant_q8_0(W)
                f.write(data)
            # Pad to alignment (except last)
            if idx < n_tensors - 1:
                cur = f.tell()
                nxt = hdr_size + t['off'] + t['nbytes']
                nxt_al = ((nxt + ALIGN - 1) // ALIGN) * ALIGN
                if cur < nxt_al: f.write(b'\x00' * (nxt_al - cur))
            if (idx + 1) % 50 == 0:
                print(f"  {idx+1}/{n_tensors}, {f.tell()/1e9:.2f} GB, {time.perf_counter()-t0:.0f}s")

        final = f.tell()

    elapsed = time.perf_counter() - t0
    total_elapsed = time.perf_counter() - t_start
    fsize = os.path.getsize(GGUF_PATH)
    print(f"\nGGUF v5 written: {fsize/1e9:.2f} GB in {elapsed:.0f}s")
    print(f"Total pipeline time: {total_elapsed:.0f}s")

    # 8. Test with llama-cli
    print("\nStep 6: Testing with llama-cli (CPU mode)...")
    import subprocess
    cli_path = "/content/llama.cpp/build/bin/llama-cli"
    if os.path.exists(cli_path):
        result = subprocess.run(
            [cli_path, "-m", GGUF_PATH, "-p", "The meaning of life is", "-n", "30",
             "--temp", "0", "-ngl", "0", "--no-warmup"],
            capture_output=True, text=True, timeout=300
        )
        print("=== STDERR (last 20 lines) ===")
        for line in result.stderr.strip().split('\n')[-20:]:
            print(line[:200])
        print("\n=== STDOUT ===")
        print(result.stdout[-3000:] if len(result.stdout) > 3000 else result.stdout)
    else:
        print("  llama-cli not found, skipping test")

if __name__ == "__main__":
    main()