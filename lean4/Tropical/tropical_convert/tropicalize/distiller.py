"""
Knowledge distillation trainer for tropical models.

Uses the original (teacher) model's output distribution to train the
tropical (student) model to match its behaviour. The training procedure:

1. **Logit matching**: KL-divergence between teacher and student output
   distributions at configurable temperature.
2. **Hidden state alignment**: Optional MSE loss between intermediate
   hidden representations.
3. **Temperature annealing**: Gradually reduce tropical layer temperatures
   from 1.0 → 0 to move from soft (LogSumExp) to hard (max) tropical ops.

The distillation uses the teacher model's own tokenizer to generate
training data from a text corpus, ensuring domain coverage.
"""

from __future__ import annotations

import json
import logging
import math
import os
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional, List

import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.utils.data import DataLoader, Dataset

from .layers import TropicalCausalLM, TropicalLinear
from .cache import get_checkpoint_dir, is_cached, mark_complete

logger = logging.getLogger(__name__)


@dataclass
class DistillationConfig:
    """Configuration for knowledge distillation training."""

    # Training
    num_epochs: int = 3
    batch_size: int = 4
    learning_rate: float = 1e-4
    weight_decay: float = 0.01
    warmup_steps: int = 100
    max_grad_norm: float = 1.0
    seq_length: int = 512

    # Distillation
    distill_temperature: float = 2.0
    alpha_logit: float = 0.7       # Weight for logit matching loss
    alpha_hidden: float = 0.1      # Weight for hidden state matching
    alpha_ce: float = 0.2          # Weight for hard-label cross-entropy

    # Tropical temperature annealing
    anneal_tropical_temp: bool = True
    final_tropical_temp: float = 0.01  # Near-zero = pure tropical
    anneal_schedule: str = "cosine"     # "linear", "cosine", "exponential"

    # Checkpointing
    save_every_steps: int = 500
    eval_every_steps: int = 100
    log_every_steps: int = 10

    # Data
    max_train_samples: int = 10000
    corpus_texts: Optional[List[str]] = None

    # Device
    device: str = "auto"

    def effective_device(self) -> torch.device:
        if self.device == "auto":
            if torch.cuda.is_available():
                return torch.device("cuda")
            elif hasattr(torch.backends, "mps") and torch.backends.mps.is_available():
                return torch.device("mps")
            return torch.device("cpu")
        return torch.device(self.device)


class TextDataset(Dataset):
    """Simple dataset of tokenized text chunks."""

    def __init__(self, token_ids: torch.LongTensor, seq_length: int):
        self.seq_length = seq_length
        # Reshape into chunks
        n_chunks = len(token_ids) // (seq_length + 1)
        if n_chunks == 0:
            # Pad if too short
            padding = torch.zeros(seq_length + 1 - len(token_ids), dtype=torch.long)
            token_ids = torch.cat([token_ids, padding])
            n_chunks = 1
        self.chunks = token_ids[: n_chunks * (seq_length + 1)].view(n_chunks, seq_length + 1)

    def __len__(self):
        return len(self.chunks)

    def __getitem__(self, idx):
        chunk = self.chunks[idx]
        return {
            "input_ids": chunk[:-1],
            "labels": chunk[1:],
        }


def _get_default_corpus() -> list[str]:
    """Generate a default training corpus for distillation."""
    # A diverse set of prompts that exercise reasoning capabilities
    return [
        # Code
        "def fibonacci(n):\n    if n <= 1:\n        return n\n    return fibonacci(n-1) + fibonacci(n-2)\n\n",
        "class BinaryTree:\n    def __init__(self, value):\n        self.value = value\n        self.left = None\n        self.right = None\n\n",
        "import numpy as np\n\ndef matrix_multiply(A, B):\n    return np.dot(A, B)\n\n",
        # Math reasoning
        "Let's solve this step by step. First, we need to find the derivative of f(x) = x^3 + 2x^2 - 5x + 1.\n",
        "To prove that sqrt(2) is irrational, assume for contradiction that sqrt(2) = p/q where p,q are integers.\n",
        "The fundamental theorem of calculus states that integration and differentiation are inverse operations.\n",
        # General text
        "The architecture of modern neural networks has evolved significantly since the introduction of transformers.\n",
        "In distributed systems, consensus algorithms ensure that all nodes agree on a single value.\n",
        "Machine learning models can be broadly categorized into supervised, unsupervised, and reinforcement learning.\n",
        "The tropical semiring replaces addition with maximum and multiplication with addition.\n",
        # Instruction following
        "Question: What is the capital of France?\nAnswer: The capital of France is Paris.\n",
        "Task: Write a function that reverses a string.\nSolution: def reverse(s): return s[::-1]\n",
        # Longer reasoning
        "Let me think about this problem carefully.\n\nFirst, I need to understand what we're asked to find.\n",
        "Here's my approach:\n1. Break down the problem\n2. Solve each part\n3. Combine the results\n",
        # Technical documentation
        "## API Reference\n\n### `convert(model_name: str) -> Model`\n\nConverts a standard model to tropical architecture.\n",
        "The time complexity of this algorithm is O(n log n) due to the sorting step.\n",
    ] * 50  # Repeat for more training data


def prepare_dataset(
    tokenizer,
    config: DistillationConfig,
) -> TextDataset:
    """Prepare training dataset from corpus texts."""
    corpus = config.corpus_texts or _get_default_corpus()

    # Tokenize all texts
    all_tokens = []
    for text in corpus:
        tokens = tokenizer.encode(text, add_special_tokens=False)
        all_tokens.extend(tokens)
        if len(all_tokens) >= config.max_train_samples * config.seq_length:
            break

    token_ids = torch.tensor(all_tokens, dtype=torch.long)
    dataset = TextDataset(token_ids, config.seq_length)
    logger.info(f"Prepared dataset: {len(dataset)} chunks of length {config.seq_length}")
    return dataset


def _get_tropical_temperature_schedule(
    step: int,
    total_steps: int,
    initial_temp: float,
    final_temp: float,
    schedule: str,
) -> float:
    """Compute the tropical temperature at a given step."""
    progress = min(step / max(total_steps, 1), 1.0)

    if schedule == "linear":
        return initial_temp + (final_temp - initial_temp) * progress
    elif schedule == "cosine":
        return final_temp + (initial_temp - final_temp) * 0.5 * (1 + math.cos(math.pi * progress))
    elif schedule == "exponential":
        if initial_temp <= 0 or final_temp <= 0:
            return final_temp
        log_ratio = math.log(final_temp / initial_temp)
        return initial_temp * math.exp(log_ratio * progress)
    else:
        return initial_temp


def _set_tropical_temperatures(model: TropicalCausalLM, temperature: float):
    """Set all tropical layer temperatures to the given value."""
    log_temp = math.log(max(temperature, 1e-8))
    for module in model.modules():
        if isinstance(module, TropicalLinear):
            module.log_temperature.data.fill_(log_temp)


def _compute_distillation_loss(
    student_logits: torch.Tensor,
    teacher_logits: torch.Tensor,
    labels: torch.Tensor,
    config: DistillationConfig,
) -> tuple[torch.Tensor, dict]:
    """
    Compute the combined distillation loss.

    Components:
    1. KL divergence between softened teacher/student distributions
    2. Standard cross-entropy on hard labels
    """
    vocab_size = student_logits.shape[-1]
    T = config.distill_temperature

    # Shift for causal LM
    s_logits = student_logits[..., :-1, :].contiguous().view(-1, vocab_size)
    t_logits = teacher_logits[..., :-1, :].contiguous().view(-1, vocab_size)
    shifted_labels = labels[..., 1:].contiguous().view(-1)

    # 1. KL divergence with temperature scaling
    s_probs = F.log_softmax(s_logits / T, dim=-1)
    t_probs = F.softmax(t_logits / T, dim=-1)
    kl_loss = F.kl_div(s_probs, t_probs, reduction="batchmean") * (T * T)

    # 2. Hard-label cross-entropy
    ce_loss = F.cross_entropy(s_logits, shifted_labels, ignore_index=-100)

    # Combined loss
    total_loss = config.alpha_logit * kl_loss + config.alpha_ce * ce_loss

    metrics = {
        "kl_loss": kl_loss.item(),
        "ce_loss": ce_loss.item(),
        "total_loss": total_loss.item(),
    }

    return total_loss, metrics


def distill(
    teacher: nn.Module,
    student: TropicalCausalLM,
    tokenizer,
    config: DistillationConfig,
    model_name: str = "unknown",
) -> TropicalCausalLM:
    """
    Run knowledge distillation from teacher to tropical student.

    Args:
        teacher: Original HuggingFace model (frozen)
        student: Tropical model to train
        tokenizer: Shared tokenizer
        config: Training configuration
        model_name: For cache key

    Returns:
        Trained tropical student model
    """
    device = config.effective_device()
    logger.info(f"Training on device: {device}")

    checkpoint_dir = get_checkpoint_dir(model_name)
    checkpoint_dir.mkdir(parents=True, exist_ok=True)

    # Check for existing checkpoint
    latest_ckpt = _find_latest_checkpoint(checkpoint_dir)
    start_step = 0

    # Prepare models
    teacher = teacher.to(device).eval()
    student = student.to(device).train()

    # Freeze teacher
    for param in teacher.parameters():
        param.requires_grad = False

    # Prepare dataset
    dataset = prepare_dataset(tokenizer, config)
    dataloader = DataLoader(
        dataset, batch_size=config.batch_size, shuffle=True,
        drop_last=True, num_workers=0,
    )

    # Optimizer — separate lr for temperature params
    temp_params = []
    other_params = []
    for name, param in student.named_parameters():
        if "log_temperature" in name:
            temp_params.append(param)
        else:
            other_params.append(param)

    optimizer = torch.optim.AdamW([
        {"params": other_params, "lr": config.learning_rate},
        {"params": temp_params, "lr": config.learning_rate * 0.1},
    ], weight_decay=config.weight_decay)

    # Load checkpoint if available
    if latest_ckpt is not None:
        logger.info(f"Resuming from checkpoint: {latest_ckpt}")
        ckpt = torch.load(latest_ckpt, map_location=device, weights_only=False)
        student.load_state_dict(ckpt["student_state_dict"])
        optimizer.load_state_dict(ckpt["optimizer_state_dict"])
        start_step = ckpt.get("step", 0)

    # Training loop
    total_steps = config.num_epochs * len(dataloader)
    initial_temp = 1.0
    global_step = start_step
    best_loss = float("inf")

    logger.info(f"Starting distillation: {total_steps} total steps, resuming from step {start_step}")
    logger.info(f"Student parameters: {sum(p.numel() for p in student.parameters()):,}")

    for epoch in range(config.num_epochs):
        epoch_loss = 0.0
        epoch_steps = 0

        for batch_idx, batch in enumerate(dataloader):
            if global_step < start_step:
                global_step += 1
                continue

            input_ids = batch["input_ids"].to(device)
            labels = batch["labels"].to(device)

            # Anneal tropical temperature
            if config.anneal_tropical_temp:
                trop_temp = _get_tropical_temperature_schedule(
                    global_step, total_steps,
                    initial_temp, config.final_tropical_temp,
                    config.anneal_schedule,
                )
                _set_tropical_temperatures(student, trop_temp)

            # Learning rate warmup
            if global_step < config.warmup_steps:
                lr_scale = (global_step + 1) / config.warmup_steps
                for pg in optimizer.param_groups:
                    pg["lr"] = pg["lr"] * lr_scale / max(lr_scale, 1e-8)

            # Forward pass — teacher
            with torch.no_grad():
                teacher_outputs = teacher(input_ids)
                teacher_logits = teacher_outputs.logits if hasattr(teacher_outputs, "logits") else teacher_outputs["logits"]

            # Forward pass — student
            student_outputs = student(input_ids, labels=labels)
            student_logits = student_outputs["logits"]

            # Compute loss
            loss, metrics = _compute_distillation_loss(
                student_logits, teacher_logits, labels, config
            )

            # Backward
            optimizer.zero_grad()
            loss.backward()
            torch.nn.utils.clip_grad_norm_(student.parameters(), config.max_grad_norm)
            optimizer.step()

            epoch_loss += metrics["total_loss"]
            epoch_steps += 1
            global_step += 1

            # Logging
            if global_step % config.log_every_steps == 0:
                avg_loss = epoch_loss / max(epoch_steps, 1)
                trop_t = trop_temp if config.anneal_tropical_temp else "fixed"
                logger.info(
                    f"Step {global_step}/{total_steps} | "
                    f"Loss: {metrics['total_loss']:.4f} (KL: {metrics['kl_loss']:.4f}, "
                    f"CE: {metrics['ce_loss']:.4f}) | "
                    f"Tropical τ: {trop_t if isinstance(trop_t, str) else f'{trop_t:.4f}'}"
                )

            # Checkpoint
            if global_step % config.save_every_steps == 0:
                ckpt_path = checkpoint_dir / f"checkpoint_{global_step:08d}.pt"
                torch.save({
                    "step": global_step,
                    "student_state_dict": student.state_dict(),
                    "optimizer_state_dict": optimizer.state_dict(),
                    "metrics": metrics,
                    "config": {
                        "num_epochs": config.num_epochs,
                        "batch_size": config.batch_size,
                        "learning_rate": config.learning_rate,
                    },
                }, ckpt_path)
                logger.info(f"Saved checkpoint: {ckpt_path}")

            # Track best
            if metrics["total_loss"] < best_loss:
                best_loss = metrics["total_loss"]

        avg_epoch_loss = epoch_loss / max(epoch_steps, 1)
        logger.info(f"Epoch {epoch+1}/{config.num_epochs} complete. Avg loss: {avg_epoch_loss:.4f}")

    # Set final tropical temperature
    if config.anneal_tropical_temp:
        _set_tropical_temperatures(student, config.final_tropical_temp)

    logger.info(f"Distillation complete. Best loss: {best_loss:.4f}")
    return student


def _find_latest_checkpoint(checkpoint_dir: Path) -> Optional[Path]:
    """Find the latest checkpoint in the directory."""
    ckpts = sorted(checkpoint_dir.glob("checkpoint_*.pt"))
    return ckpts[-1] if ckpts else None
