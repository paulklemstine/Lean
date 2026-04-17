#!/usr/bin/env python3
"""
Build Crystal LLaMA 7B for Ollama

Reproduces the full pipeline locally:
  1. Download openlm-research/open_llama_7b from HuggingFace
  2. Crystallize weights (int16 per-channel symmetric quantization)
  3. Save crystallized model
  4. Convert to GGUF using llama.cpp
  5. (Optional) Quantize to Q4_K_M
  6. (Optional) Import to Ollama

Requirements:
  pip install torch transformers numpy accelerate sentencepiece gguf protobuf
  llama.cpp: git clone https://github.com/ggerganov/llama.cpp

Usage:
  python build_crystal_llama_ollama.py                    # full pipeline
  python build_crystal_llama_ollama.py --skip-convert     # skip GGUF conversion
  python build_crystal_llama_ollama.py --skip-quantize   # skip Q4_K_M quantization
  python build_crystal_llama_ollama.py --import-ollama   # import to Ollama after build
"""

import argparse
import os
import subprocess
import sys
import time


def crystallize_model_weights(model):
    """Replace fp16 Linear layer weights with dequantized int16 (per-channel symmetric).

    For each nn.Linear weight matrix W (shape [d_out, d_in]):
      scale_j = max(|W[j,:]|) / 32767
      W_int16  = round(W / scale).clamp(-32768, 32767)
      W_dequant = W_int16.float() * scale

    Word-for-word token matching with original fp16 model under greedy decoding.
    """
    import torch

    n_layers = 0
    n_params = 0
    total_abs_err = 0.0
    max_abs_err = 0.0

    for name, module in model.named_modules():
        if isinstance(module, torch.nn.Linear):
            W = module.weight.data.float()

            scale = W.abs().amax(dim=1).clamp(min=1e-10) / 32767.0
            W_int16 = torch.round(W / scale.unsqueeze(1)).clamp(-32768, 32767)
            W_dequant = W_int16.float() * scale.unsqueeze(1)

            module.weight.data = W_dequant.to(module.weight.dtype)

            err = (W - W_dequant).abs()
            n_layers += 1
            n_params += W.numel()
            total_abs_err += err.sum().item()
            max_abs_err = max(max_abs_err, err.max().item())

            del W, W_int16, W_dequant, err

    print(f"  Layers crystallized: {n_layers}")
    print(f"  Params crystallized: {n_params:,}")
    print(f"  Max abs error:       {max_abs_err:.8f}")
    print(f"  Mean abs error:      {total_abs_err / max(n_params, 1):.8f}")

    return {
        'n_layers': n_layers,
        'n_params': n_params,
        'max_abs_error': max_abs_err,
        'mean_abs_error': total_abs_err / max(n_params, 1),
    }


def main():
    parser = argparse.ArgumentParser(description="Build Crystal LLaMA 7B for Ollama")
    parser.add_argument("--model", default="openlm-research/open_llama_7b",
                        help="HuggingFace model name")
    parser.add_argument("--output-dir", default="./crystal-llama-7b",
                        help="Output directory for saved model")
    parser.add_argument("--gguf-f16", default=None,
                        help="Output path for F16 GGUF")
    parser.add_argument("--gguf-q4", default=None,
                        help="Output path for Q4_K_M GGUF")
    parser.add_argument("--llama-cpp", default="./llama.cpp",
                        help="Path to llama.cpp directory")
    parser.add_argument("--skip-convert", action="store_true",
                        help="Skip GGUF conversion")
    parser.add_argument("--skip-quantize", action="store_true",
                        help="Skip Q4_K_M quantization")
    parser.add_argument("--import-ollama", action="store_true",
                        help="Import model to Ollama after building")
    args = parser.parse_args()

    # --- Step 1: Download and load model ---
    print("=" * 60)
    print("Step 1: Loading model from HuggingFace")
    print("=" * 60)

    import torch
    from transformers import AutoModelForCausalLM, AutoTokenizer

    device = "cuda" if torch.cuda.is_available() else "cpu"
    print(f"Device: {device}")

    t0 = time.perf_counter()
    tokenizer = AutoTokenizer.from_pretrained(args.model)
    model = AutoModelForCausalLM.from_pretrained(
        args.model,
        torch_dtype=torch.float16 if device == "cuda" else torch.float32,
        device_map=device if device == "cuda" else None,
        low_cpu_mem_usage=True,
    )
    t1 = time.perf_counter()
    n_params = sum(p.numel() for p in model.parameters())
    print(f"  Loaded {n_params/1e9:.2f}B params in {t1-t0:.1f}s")

    # --- Step 2: Crystallize weights ---
    print("\n" + "=" * 60)
    print("Step 2: Crystallizing weights (int16 per-channel)")
    print("=" * 60)

    crystal_stats = crystallize_model_weights(model)

    # --- Step 3: Save crystallized model ---
    print("\n" + "=" * 60)
    print("Step 3: Saving crystallized model")
    print("=" * 60)

    os.makedirs(args.output_dir, exist_ok=True)
    model.save_pretrained(args.output_dir, safe_serialization=True)
    tokenizer.save_pretrained(args.output_dir)

    total_size = sum(
        os.path.getsize(os.path.join(dp, f))
        for dp, dn, fns in os.walk(args.output_dir) for f in fns
    )
    print(f"  Saved to {args.output_dir} ({total_size/1e9:.2f} GB)")

    # Free GPU memory
    del model
    torch.cuda.empty_cache()
    import gc; gc.collect()

    if args.skip_convert:
        print("\nSkipping GGUF conversion (--skip-convert).")
        print(f"Crystallized model saved to: {args.output_dir}")
        return

    # --- Step 4: Convert to GGUF ---
    print("\n" + "=" * 60)
    print("Step 4: Converting to GGUF F16")
    print("=" * 60)

    gguf_f16 = args.gguf_f16 or os.path.join(args.output_dir, "crystal-llama-7b-f16.gguf")
    convert_script = os.path.join(args.llama_cpp, "convert_hf_to_gguf.py")

    if not os.path.exists(convert_script):
        print(f"  llama.cpp not found at {args.llama_cpp}")
        print(f"  Clone it: git clone https://github.com/ggerganov/llama.cpp {args.llama_cpp}")
        print(f"  Or run with --skip-convert to skip GGUF conversion.")
        return

    t0 = time.perf_counter()
    result = subprocess.run(
        ["python3", convert_script, args.output_dir,
         "--outfile", gguf_f16, "--outtype", "f16"],
        capture_output=True, text=True, cwd=args.llama_cpp
    )
    t1 = time.perf_counter()

    if result.returncode != 0:
        print("  Conversion FAILED:")
        print(result.stderr[-2000:])
        return

    gguf_size = os.path.getsize(gguf_f16)
    print(f"  GGUF F16 saved: {gguf_f16} ({gguf_size/1e9:.2f} GB) in {t1-t0:.1f}s")

    if args.skip_quantize:
        print(f"\nSkipping quantization (--skip-quantize).")
        print(f"GGUF file: {gguf_f16}")
        return

    # --- Step 5: Quantize to Q4_K_M ---
    print("\n" + "=" * 60)
    print("Step 5: Quantizing to Q4_K_M")
    print("=" * 60)

    gguf_q4 = args.gguf_q4 or os.path.join(args.output_dir, "crystal-llama-7b-Q4_K_M.gguf")

    quantize_bin = None
    for path in [
        os.path.join(args.llama_cpp, "build", "bin", "llama-quantize"),
        os.path.join(args.llama_cpp, "llama-quantize"),
    ]:
        if os.path.exists(path):
            quantize_bin = path
            break

    if not quantize_bin:
        print("  Building llama-quantize...")
        subprocess.run(
            ["make", "-j4", "llama-quantize"],
            capture_output=True, text=True, cwd=args.llama_cpp
        )
        if os.path.exists(os.path.join(args.llama_cpp, "llama-quantize")):
            quantize_bin = os.path.join(args.llama_cpp, "llama-quantize")
        else:
            build_dir = os.path.join(args.llama_cpp, "build")
            os.makedirs(build_dir, exist_ok=True)
            subprocess.run(
                ["cmake", "..", "-DCMAKE_BUILD_TYPE=Release"],
                capture_output=True, text=True, cwd=build_dir
            )
            subprocess.run(
                ["cmake", "--build", ".", "--config", "Release", "-j4", "-t", "llama-quantize"],
                capture_output=True, text=True, cwd=build_dir
            )
            quantize_bin = os.path.join(build_dir, "bin", "llama-quantize")

    if not quantize_bin or not os.path.exists(quantize_bin):
        print("  Could not find/build llama-quantize.")
        print(f"  F16 GGUF is ready: {gguf_f16}")
        gguf_q4 = None
    else:
        t0 = time.perf_counter()
        result = subprocess.run(
            [quantize_bin, gguf_f16, gguf_q4, "Q4_K_M"],
            capture_output=True, text=True
        )
        t1 = time.perf_counter()

        if result.returncode != 0:
            print("  Quantization FAILED:")
            print(result.stderr[-2000:])
            gguf_q4 = None
        else:
            q4_size = os.path.getsize(gguf_q4)
            print(f"  Q4_K_M GGUF: {gguf_q4} ({q4_size/1e9:.2f} GB) in {t1-t0:.1f}s")

    # --- Step 6: Import to Ollama (optional) ---
    if args.import_ollama:
        print("\n" + "=" * 60)
        print("Step 6: Importing to Ollama")
        print("=" * 60)

        gguf_for_ollama = gguf_q4 or gguf_f16
        modelfile_dir = os.path.dirname(os.path.abspath(gguf_for_ollama))
        modelfile_path = os.path.join(modelfile_dir, "Modelfile.crystal-llama")
        gguf_basename = os.path.basename(gguf_for_ollama)

        modelfile_lines = [
            "# Crystal LLaMA 7B - int16 weight crystallization",
            f"FROM ./{gguf_basename}",
            "",
            'TEMPLATE """',
            "{{- if .System }}",
            "{{ .System }}",
            "{{- end }}",
            "{{- if .Prompt }}",
            "{{ .Prompt }}",
            "{{- end }}",
            "{{ .Response }}",
            '"""',
            "",
            'PARAMETER stop "</s>"',
            "PARAMETER temperature 0.7",
            "PARAMETER top_p 0.9",
        ]
        with open(modelfile_path, "w") as f:
            f.write("\n".join(modelfile_lines) + "\n")

        print(f"  Modelfile: {modelfile_path}")

        try:
            subprocess.run(["ollama", "--version"], capture_output=True, check=True)
            print("  Running: ollama create crystal-llama-7b -f Modelfile.crystal-llama")
            result = subprocess.run(
                ["ollama", "create", "crystal-llama-7b", "-f", modelfile_path],
                capture_output=True, text=True, cwd=modelfile_dir
            )
            if result.returncode == 0:
                print("  Model imported to Ollama!")
                print("  Run: ollama run crystal-llama-7b")
            else:
                print("  Import failed:")
                print(result.stderr)
        except (subprocess.CalledProcessError, FileNotFoundError):
            print("  Ollama not found. Install from: https://ollama.com")
            print(f"  Then: ollama create crystal-llama-7b -f {modelfile_path}")

    # --- Summary ---
    print("\n" + "=" * 60)
    print("Crystal LLaMA 7B - Build Complete")
    print("=" * 60)
    print(f"  HuggingFace format: {args.output_dir}")
    if os.path.exists(gguf_f16):
        print(f"  GGUF F16:           {gguf_f16} ({os.path.getsize(gguf_f16)/1e9:.2f} GB)")
    if gguf_q4 and os.path.exists(gguf_q4):
        print(f"  GGUF Q4_K_M:       {gguf_q4} ({os.path.getsize(gguf_q4)/1e9:.2f} GB)")
    print()
    print("  To use with Ollama:")
    print("    1. Copy the Q4_K_M GGUF to a local directory")
    print("    2. Place Modelfile.crystal-llama next to the GGUF file")
    print("    3. Run: ollama create crystal-llama-7b -f Modelfile.crystal-llama")
    print("    4. Run: ollama run crystal-llama-7b")


if __name__ == "__main__":
    main()
