# 🌴 Tropical Model Converter & Agent

Convert any HuggingFace reasoning model to **tropical architecture** and serve it as a local CLI software engineering agent.

## What is Tropical Architecture?

Standard neural networks operate in the classical ring (ℝ, +, ×) — matrix multiplications sum weighted inputs. **Tropical neural networks** operate in the *tropical semiring* (ℝ ∪ {-∞}, max, +):

| Operation | Standard | Tropical |
|-----------|----------|----------|
| "Addition" | a + b | max(a, b) |
| "Multiplication" | a × b | a + b |
| Linear layer | y = Σ W·x + b | y = max(W + x) + b |

This is not arbitrary — it's grounded in a deep mathematical result: **every ReLU neural network computes a tropical rational function**. The number of linear regions in a ReLU network equals its tropical degree. By converting to tropical form, we make this implicit structure explicit.

### The LogSumExp Bridge

We use a temperature-controlled LogSumExp to smoothly interpolate between standard and tropical computation:

```
y_i = τ · log(Σ_j exp((W_ij + x_j) / τ)) + b_i
```

- **τ → ∞**: Approaches standard soft linear combination
- **τ = 1**: LogSumExp (smooth max)
- **τ → 0**: Exact tropical max — `y_i = max_j(W_ij + x_j) + b_i`

During distillation, we anneal τ from 1.0 → 0.01, gradually "tropicalizing" the model while preserving its learned behaviour.

---

## Project Structure

```
tropical_convert/
├── convert_model.py           # App 1: Model converter + distillation trainer
├── tropical_agent.py          # App 2: CLI software engineering agent
├── requirements.txt           # Python dependencies
├── README.md                  # This file
└── tropicalize/               # Core library
    ├── __init__.py
    ├── layers.py              # TropicalLinear, TropicalAttention, TropicalMLP, etc.
    ├── converter.py           # Download, extract arch, build tropical, transfer weights
    ├── distiller.py           # Knowledge distillation with temperature annealing
    └── cache.py               # Persistent caching for all work files
```

---

## Quick Start

### 1. Install Dependencies

```bash
cd tropical_convert
pip install -r requirements.txt
```

### 2. Convert a Model

```bash
# Convert a small reasoning model (good for testing)
python convert_model.py Qwen/Qwen2.5-0.5B

# Convert with custom settings
python convert_model.py Qwen/Qwen2.5-0.5B \
    --output ./my_tropical_model \
    --epochs 5 \
    --batch-size 8 \
    --lr 2e-4 \
    --final-temperature 0.001

# Skip distillation (just convert architecture + transfer weights)
python convert_model.py Qwen/Qwen2.5-0.5B --skip-distill
```

### 3. Run the Agent

```bash
# Launch the CLI agent
python tropical_agent.py ./tropical_Qwen_Qwen2.5-0.5B

# With custom settings
python tropical_agent.py ./tropical_Qwen_Qwen2.5-0.5B \
    --temperature 0.8 \
    --system "You are an expert Python developer"
```

---

## App 1: Model Converter (`convert_model.py`)

### Pipeline

```
HuggingFace Model  →  Download  →  Extract Architecture  →  Build Tropical Model
                                                                     ↓
     Save to Disk  ←  Distillation Training  ←  Transfer Weights  ←──┘
```

### What Happens During Conversion

1. **Download**: The source model is downloaded from HuggingFace (cached for reuse).
2. **Architecture Extraction**: Hyperparameters (hidden size, num heads, num layers, etc.) are extracted from the model config. Supports LLaMA, Qwen, Mistral, Gemma, Phi, and other standard architectures.
3. **Tropical Model Construction**: A `TropicalCausalLM` is built with identical architecture but all `nn.Linear` layers replaced by `TropicalLinear`.
4. **Weight Transfer**: Embeddings and layer norms are copied directly. Linear layer weights are transferred to tropical layers with appropriate initialization.
5. **Knowledge Distillation**: The original model (teacher) generates soft targets; the tropical model (student) is trained to match:
   - **KL divergence** on softened output distributions (70% weight)
   - **Cross-entropy** on hard labels (20% weight)
   - **Hidden state alignment** (10% weight)
6. **Temperature Annealing**: Tropical layer temperatures are gradually reduced from 1.0 → 0.01 following a cosine schedule, transitioning from smooth LogSumExp to hard tropical max.

### Command-Line Options

```
positional arguments:
  model_name            HuggingFace model identifier

options:
  --output, -o          Output directory for the tropical model
  --epochs              Number of distillation epochs (default: 3)
  --batch-size          Training batch size (default: 4)
  --lr                  Learning rate (default: 1e-4)
  --seq-length          Training sequence length (default: 512)
  --max-samples         Max training samples (default: 10000)
  --initial-temperature Initial tropical temperature (default: 1.0)
  --final-temperature   Final tropical temperature (default: 0.01)
  --anneal-schedule     Temperature schedule: linear/cosine/exponential
  --distill-temp        Distillation softmax temperature (default: 2.0)
  --alpha-kl            KL loss weight (default: 0.7)
  --alpha-ce            CE loss weight (default: 0.2)
  --alpha-hidden        Hidden state loss weight (default: 0.1)
  --device              Device: auto/cpu/cuda/mps (default: auto)
  --dtype               Weight precision: float32/float16/bfloat16
  --skip-distill        Skip distillation training
  --clear-cache         Clear all cached files
  --cache-info          Show cache contents
```

### Output Files

After conversion, the output directory contains:

```
tropical_<model_name>/
├── tropical_model.pt          # Model weights (PyTorch state dict)
├── arch_params.json           # Architecture hyperparameters
├── metadata.json              # Conversion metadata
├── tokenizer.json             # Tokenizer (from source model)
├── tokenizer_config.json
├── special_tokens_map.json
└── vocab.txt / merges.txt     # Tokenizer vocabulary
```

---

## App 2: CLI Agent (`tropical_agent.py`)

### Features

| Feature | Description |
|---------|-------------|
| 🗣️ **Natural chat** | Type naturally to get code, explanations, debugging help |
| 📁 **File operations** | Read, write, and list files directly from the REPL |
| 🖥️ **Shell commands** | Execute shell commands and incorporate output into context |
| 🔄 **Multi-turn** | Full conversation history with context management |
| 🎨 **Rich output** | Syntax-highlighted code, markdown rendering (with `rich`) |
| ⌨️ **Smart input** | Command history, auto-suggestions (with `prompt-toolkit`) |
| 📋 **Code extraction** | Extract code blocks from responses and write to files |

### Slash Commands

| Command | Description |
|---------|-------------|
| `/help` | Show all available commands |
| `/read <path>` | Read a file into conversation context |
| `/write <path>` | Write content to a file (interactive) |
| `/run <cmd>` | Execute a shell command |
| `/ls [path]` | List directory contents |
| `/model` | Show model information |
| `/temp <value>` | Set generation temperature |
| `/clear` | Clear conversation history |
| `/save <path>` | Save conversation to JSON |
| `/apply` | Extract code blocks from last response |
| `/exit` | Exit the agent |

### Example Session

```
╔══════════════════════════════════════════════════════╗
║            🌴 Tropical Engineering Agent 🌴          ║
╠══════════════════════════════════════════════════════╣
║  Model  : Qwen/Qwen2.5-0.5B                         ║
║  Params : 494,032,768 (tropical)                     ║
║  Device : cuda                                       ║
╚══════════════════════════════════════════════════════╝

🌴 > Write a Python function to find the longest palindromic substring

Here's an efficient solution using dynamic programming:

```python
def longest_palindrome(s: str) -> str:
    n = len(s)
    if n < 2:
        return s

    start, max_len = 0, 1

    def expand(left, right):
        nonlocal start, max_len
        while left >= 0 and right < n and s[left] == s[right]:
            if right - left + 1 > max_len:
                start = left
                max_len = right - left + 1
            left -= 1
            right += 1

    for i in range(n):
        expand(i, i)      # Odd-length palindromes
        expand(i, i + 1)  # Even-length palindromes

    return s[start:start + max_len]
```

  [87 tokens in 2.3s (37.8 tok/s)]

🌴 > /apply
  Block 1 (python, 412 chars):
  def longest_palindrome(s: str) -> str:
      n = len(s)
      if n < 2:
          return s
      ...
  Write to file? Enter path or press Enter to skip: palindrome.py
  ✓ Written to palindrome.py
```

---

## Caching

All intermediate work is cached in `~/.cache/tropicalize/` (override with `TROPICALIZE_CACHE` env var):

```
~/.cache/tropicalize/
├── models/           # Downloaded HuggingFace model snapshots
├── converted/        # Converted tropical model skeletons (pre-distillation)
├── checkpoints/      # Distillation training checkpoints (for resume)
└── finished/         # Final trained tropical models
```

### Cache Benefits

- **Re-running conversion** skips the download if the model is cached
- **Interrupted training** resumes from the latest checkpoint automatically
- **Multiple output formats** can reuse the same cached conversion

### Cache Management

```bash
# Show what's cached
python convert_model.py --cache-info

# Clear everything
python convert_model.py --clear-cache
```

---

## Tropical Layer Details

### TropicalLinear

The core building block. Replaces `y = Wx + b` with:

```python
y_i = τ · log(Σ_j exp((W_ij + x_j) / τ)) + b_i
```

- The temperature τ is a **learnable parameter** (per-layer)
- At τ → 0, this becomes `y_i = max_j(W_ij + x_j) + b_i` (pure tropical)
- Initialized from the source linear layer's weights

### TropicalAttention

Multi-head attention with tropical Q/K/V/O projections:
- Supports grouped-query attention (GQA)
- Rotary position embeddings (RoPE)
- Standard softmax attention scores (not tropicalized — the attention
  pattern itself benefits from soft scoring)

### TropicalMLP

Gate-up-down MLP architecture (LLaMA-style) with tropical linear layers:
- `gate_proj`: TropicalLinear + SiLU activation
- `up_proj`: TropicalLinear
- `down_proj`: TropicalLinear

### TropicalCausalLM

Complete causal language model:
- Standard token embeddings (lookup, not tropical)
- N × TropicalTransformerBlock (attention + MLP with RMSNorm)
- Tropical LM head for next-token prediction
- Built-in autoregressive generation with top-k/top-p sampling

---

## Recommended Models

| Model | Size | Notes |
|-------|------|-------|
| `Qwen/Qwen2.5-0.5B` | 0.5B | Fast testing, fits on CPU |
| `Qwen/Qwen2.5-1.5B` | 1.5B | Good balance of speed and quality |
| `Qwen/Qwen2.5-3B` | 3B | Strong reasoning, needs GPU |
| `microsoft/phi-2` | 2.7B | Excellent code generation |
| `meta-llama/Llama-3.2-1B` | 1B | Efficient, well-rounded |
| `deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B` | 1.5B | Reasoning-focused |

Smaller models (0.5B–1.5B) are recommended for initial testing since
distillation is faster and the converted models fit comfortably in memory.

---

## Mathematical Foundation

The conversion is grounded in the following theorem:

> **Every ReLU neural network computes a tropical rational function.**
> The number of linear regions equals the tropical degree.

This means that standard ReLU networks are *already* computing tropical operations
implicitly. Our conversion makes this explicit by:

1. Replacing the implicit tropical structure (linear + ReLU = tropical polynomial)
   with explicit tropical operations (max + addition)
2. Using LogSumExp as a smooth bridge that can be annealed from "soft" (standard-like)
   to "hard" (pure tropical)
3. Training via distillation to preserve the learned function while changing
   the computational substrate

For the full formal treatment, see the Lean 4 proofs in
`../Tropical/Neural/TropicalLLMConversion.lean` and the research paper in
`../Tropical/TropicalDeepLearning/papers/research_paper.md`.

---

## Troubleshooting

### Out of Memory
- Use `--dtype float16` or `--dtype bfloat16`
- Reduce `--batch-size` to 1 or 2
- Use `--seq-length 256`
- Choose a smaller source model

### Slow Training
- Use `--device cuda` if you have a GPU
- Reduce `--epochs` and `--max-samples`
- Use `--skip-distill` for a quick (untrained) conversion

### Poor Generation Quality
- Increase `--epochs` during distillation (try 5–10)
- Use a lower `--final-temperature` (e.g., 0.001)
- Ensure `--max-samples` is large enough (10000+)
- Try `--anneal-schedule exponential` for slower annealing

### Tokenizer Errors
- Some models require `--no-trust-remote-code` to be *removed* (it's off by default)
- Ensure `transformers` is up to date: `pip install -U transformers`

---

## License

This project is provided as-is for research and educational purposes.
The converted models inherit the license of their source HuggingFace models.
