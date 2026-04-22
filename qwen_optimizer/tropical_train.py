#!/usr/bin/env python3
"""
Tropical Distillation Training Script.

Trains a tropical student model from a standard teacher model using
temperature-scaled KL divergence with crystallization penalty.

Usage:
    python tropical_train.py \
        --teacher Qwen/Qwen2.5-3B-Instruct \
        --student_config student_config.json \
        --output_dir ./tropical_model \
        --epochs 3 \
        --batch_size 4 \
        --lr 5e-5 \
        --temperature 2.0 \
        --alpha 0.5 \
        --crystallization_weight 0.01
"""

import argparse
import json
import os
import time
from datetime import datetime
from typing import List, Optional

import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.utils.data import DataLoader, Dataset
from transformers import AutoModelForCausalLM, AutoTokenizer
from tqdm import tqdm

from qwen_optimizer.tropical import (
    TropicalModel,
    tropical_distillation_loss,
    crystallization_penalty,
)
from qwen_optimizer.telemetry import TelemetryLogger, TelemetryEntry


class TextDataset(Dataset):
    """Simple text dataset for distillation."""

    def __init__(self, texts: List[str], tokenizer, max_length: int = 256):
        self.samples = []
        for text in texts:
            enc = tokenizer(
                text,
                truncation=True,
                max_length=max_length,
                padding="max_length",
                return_tensors="pt",
            )
            self.samples.append(
                (enc.input_ids.squeeze(0), enc.attention_mask.squeeze(0))
            )

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, idx):
        return self.samples[idx]


def generate_synthetic_data(
    teacher: AutoModelForCausalLM,
    tokenizer: AutoTokenizer,
    num_samples: int = 100,
    max_length: int = 256,
    prompts: Optional[List[str]] = None,
) -> List[str]:
    """Generate synthetic training data from the teacher model."""
    if prompts is None:
        prompts = [
            "Explain the Pythagorean theorem:",
            "The capital of France is",
            "Solve for x: 2x + 3 = 7",
            "In quantum mechanics,",
            "The theory of relativity states",
            "The main difference between",
            "To calculate the area of a circle",
            "In machine learning, overfitting occurs when",
            "The key advantage of tropical geometry is",
            "To prove that the square root of 2 is irrational",
        ]

    texts = []
    teacher.eval()

    for i in range(num_samples):
        prompt = prompts[i % len(prompts)]
        inputs = tokenizer(prompt, return_tensors="pt").to(teacher.device)

        with torch.no_grad():
            outputs = teacher.generate(
                **inputs,
                max_new_tokens=max_length - inputs.input_ids.shape[1],
                do_sample=True,
                temperature=0.8,
                top_p=0.95,
            )

        text = tokenizer.decode(outputs[0], skip_special_tokens=True)
        texts.append(text)

    return texts


def train_tropical_model(
    teacher: AutoModelForCausalLM,
    tropical_model: TropicalModel,
    tokenizer: AutoTokenizer,
    dataset: TextDataset,
    epochs: int = 3,
    batch_size: int = 4,
    lr: float = 5e-5,
    temperature: float = 2.0,
    alpha: float = 0.5,
    crystallization_weight: float = 0.01,
    device: str = "cuda",
    output_dir: str = "./tropical_model",
):
    """Train the tropical student model via distillation."""

    teacher.eval()
    tropical_model.to(device)
    tropical_model.train()

    dataloader = DataLoader(dataset, batch_size=batch_size, shuffle=True)
    optimizer = torch.optim.AdamW(tropical_model.parameters(), lr=lr)
    scheduler = torch.optim.lr_scheduler.CosineAnnealingLR(optimizer, T_max=epochs * len(dataloader))

    logger = TelemetryLogger(os.path.join(output_dir, "telemetry.json"))

    print("=" * 60)
    print("Tropical Distillation Training")
    print("=" * 60)
    print(f"Teacher params: {sum(p.numel() for p in teacher.parameters()) / 1e6:.1f}M")
    print(f"Student params: {sum(p.numel() for p in tropical_model.parameters()) / 1e6:.1f}M")
    print(f"Epochs: {epochs}, Batch size: {batch_size}, LR: {lr}")
    print(f"Temperature: {temperature}, Alpha: {alpha}")
    print(f"Crystallization weight: {crystallization_weight}")
    print("=" * 60)

    for epoch in range(epochs):
        epoch_loss = 0.0
        epoch_ce = 0.0
        epoch_kl = 0.0
        epoch_cryst = 0.0

        pbar = tqdm(dataloader, desc=f"Epoch {epoch + 1}/{epochs}")
        for input_ids, attention_mask in pbar:
            input_ids = input_ids.to(device)
            attention_mask = attention_mask.to(device)

            # Teacher forward pass
            with torch.no_grad():
                teacher_outputs = teacher(input_ids=input_ids, attention_mask=attention_mask)
                teacher_logits = teacher_outputs.logits

            # Student forward pass
            student_logits = tropical_model(input_ids, is_causal=True)

            # Compute distillation loss
            loss, ce_loss, kl_loss, cryst_loss = _compute_loss(
                student_logits,
                teacher_logits,
                input_ids,
                temperature,
                alpha,
                crystallization_weight,
                tropical_model,
            )

            optimizer.zero_grad()
            loss.backward()
            torch.nn.utils.clip_grad_norm_(tropical_model.parameters(), 1.0)
            optimizer.step()
            scheduler.step()

            epoch_loss += loss.item()
            epoch_ce += ce_loss.item()
            epoch_kl += kl_loss.item()
            epoch_cryst += cryst_loss.item()

            pbar.set_postfix({
                "loss": f"{loss.item():.4f}",
                "ce": f"{ce_loss.item():.4f}",
                "kl": f"{kl_loss.item():.4f}",
                "cryst": f"{cryst_loss.item():.4f}",
            })

        avg_loss = epoch_loss / len(dataloader)
        avg_ce = epoch_ce / len(dataloader)
        avg_kl = epoch_kl / len(dataloader)
        avg_cryst = epoch_cryst / len(dataloader)

        print(f"\nEpoch {epoch + 1} Summary:")
        print(f"  Loss: {avg_loss:.4f} | CE: {avg_ce:.4f} | KL: {avg_kl:.4f} | Cryst: {avg_cryst:.4f}")

        logger.log(TelemetryEntry(
            timestamp=datetime.utcnow().isoformat(),
            stage=f"tropical_train_epoch_{epoch + 1}",
            model_name="TropicalStudent",
            quantization="tropical",
            vram_mb=get_vram_mb(),
            tokens_per_sec_prefill=0,
            tokens_per_sec_decode=0,
            perplexity=None,
            latency_ttft_ms=0,
            latency_tpot_ms=0,
            notes=f"loss={avg_loss:.4f}, ce={avg_ce:.4f}, kl={avg_kl:.4f}, cryst={avg_cryst:.4f}",
        ))

    # Save model
    os.makedirs(output_dir, exist_ok=True)
    torch.save(tropical_model.state_dict(), os.path.join(output_dir, "tropical_model.pt"))
    print(f"\nModel saved to {output_dir}")

    return tropical_model


def _compute_loss(
    student_logits: torch.Tensor,
    teacher_logits: torch.Tensor,
    labels: torch.Tensor,
    temperature: float,
    alpha: float,
    crystallization_weight: float,
    model: TropicalModel,
):
    """Compute the distillation loss with crystallization penalty."""
    # CE loss
    ce_loss = F.cross_entropy(
        student_logits.view(-1, student_logits.size(-1)),
        labels.view(-1),
        ignore_index=-100,
    )

    # KL loss
    student_soft = F.log_softmax(student_logits / temperature, dim=-1)
    teacher_soft = F.softmax(teacher_logits / temperature, dim=-1)
    kl_loss = F.kl_div(
        student_soft.view(-1, student_logits.size(-1)),
        teacher_soft.view(-1, teacher_logits.size(-1)),
        reduction="batchmean",
    ) * (temperature ** 2)

    # Crystallization penalty
    cryst_loss = torch.tensor(0.0, device=student_logits.device)
    if crystallization_weight > 0:
        for param in model.parameters():
            cryst_loss = cryst_loss + crystallization_penalty(param)

    total_loss = (1 - alpha) * ce_loss + alpha * kl_loss + crystallization_weight * cryst_loss
    return total_loss, ce_loss, kl_loss, cryst_loss


def get_vram_mb() -> float:
    if torch.cuda.is_available():
        return torch.cuda.memory_allocated() / 1024**2
    return 0.0


def main():
    parser = argparse.ArgumentParser(description="Tropical Distillation Training")
    parser.add_argument("--teacher", type=str, required=True, help="Teacher model name or path")
    parser.add_argument("--student_config", type=str, default=None, help="Student model config JSON")
    parser.add_argument("--output_dir", type=str, default="./tropical_model")
    parser.add_argument("--epochs", type=int, default=3)
    parser.add_argument("--batch_size", type=int, default=4)
    parser.add_argument("--lr", type=float, default=5e-5)
    parser.add_argument("--temperature", type=float, default=2.0)
    parser.add_argument("--alpha", type=float, default=0.5)
    parser.add_argument("--crystallization_weight", type=float, default=0.01)
    parser.add_argument("--num_samples", type=int, default=100)
    parser.add_argument("--max_length", type=int, default=256)
    parser.add_argument("--device", type=str, default="cuda" if torch.cuda.is_available() else "cpu")
    args = parser.parse_args()

    # Load teacher
    print(f"Loading teacher: {args.teacher}")
    teacher = AutoModelForCausalLM.from_pretrained(
        args.teacher,
        torch_dtype=torch.float16,
        device_map="auto",
        trust_remote_code=True,
    )
    tokenizer = AutoTokenizer.from_pretrained(args.teacher, trust_remote_code=True)

    # Create tropical student
    if args.student_config:
        with open(args.student_config, "r") as f:
            config = json.load(f)
    else:
        # Default: small tropical model
        config = {
            "vocab_size": teacher.config.vocab_size,
            "d_model": 512,
            "num_layers": 6,
            "num_heads": 8,
            "d_ff": 1024,
            "max_seq_len": 2048,
            "dropout": 0.1,
            "hard_attention": False,
        }

    tropical_model = TropicalModel(**config)

    # Generate synthetic data
    print(f"Generating {args.num_samples} synthetic samples...")
    texts = generate_synthetic_data(
        teacher,
        tokenizer,
        num_samples=args.num_samples,
        max_length=args.max_length,
    )
    dataset = TextDataset(texts, tokenizer, max_length=args.max_length)

    # Train
    train_tropical_model(
        teacher=teacher,
        tropical_model=tropical_model,
        tokenizer=tokenizer,
        dataset=dataset,
        epochs=args.epochs,
        batch_size=args.batch_size,
        lr=args.lr,
        temperature=args.temperature,
        alpha=args.alpha,
        crystallization_weight=args.crystallization_weight,
        device=args.device,
        output_dir=args.output_dir,
    )

    print("\nTraining complete!")


if __name__ == "__main__":
    main()
