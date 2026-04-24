"""Training utilities for Crystalline models with distillation and crystallization.

Reference: DistillationLoss.lean, NeuralCompilationTeams.lean
"""

from typing import Optional

import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.utils.data import DataLoader, Dataset
from tqdm import tqdm

from .crystallize import crystallization_penalty


def crystalline_distillation_loss(
    student_logits: torch.Tensor,
    teacher_logits: torch.Tensor,
    labels: torch.Tensor,
    temperature: float = 2.0,
    alpha: float = 0.5,
) -> torch.Tensor:
    """Distillation loss combining hard labels and soft teacher targets.

    L = (1 - α) * L_CE(student, labels) + α * T^2 * L_KL(student/T, teacher/T)

    Args:
        student_logits: (batch, seq_len, vocab_size)
        teacher_logits: (batch, seq_len, vocab_size)
        labels: (batch, seq_len)
        temperature: Softmax temperature for distillation
        alpha: Balance between hard loss (0) and soft loss (1)

    Returns:
        loss: Scalar tensor
    """
    # Hard loss
    hard_loss = F.cross_entropy(
        student_logits.reshape(-1, student_logits.size(-1)),
        labels.reshape(-1),
        ignore_index=-100,
        reduction='mean',
    )

    # Soft loss (KL divergence)
    student_probs = F.log_softmax(student_logits / temperature, dim=-1)
    teacher_probs = F.softmax(teacher_logits / temperature, dim=-1)

    kl_loss = F.kl_div(
        student_probs.reshape(-1, student_logits.size(-1)),
        teacher_probs.reshape(-1, student_logits.size(-1)),
        reduction='batchmean',
    )

    loss = (1 - alpha) * hard_loss + alpha * (temperature ** 2) * kl_loss
    return loss


def train_crystalline_model(
    teacher: nn.Module,
    student: nn.Module,
    tokenizer,
    dataset: Dataset,
    epochs: int = 3,
    batch_size: int = 2,
    lr: float = 5e-5,
    device: str = "cuda",
    temperature: float = 2.0,
    alpha: float = 0.5,
    crystallization_weight: float = 0.005,
    output_dir: str = "./crystalline_output",
    max_length: int = 128,
) -> nn.Module:
    """Train a Crystalline student with distillation and crystallization.

    Args:
        teacher: Teacher model (e.g., Qwen2.5)
        student: CrystallineModel student
        tokenizer: Tokenizer
        dataset: torch.utils.data.Dataset yielding text strings
        epochs: Number of training epochs
        batch_size: Batch size
        lr: Learning rate
        device: "cuda" or "cpu"
        temperature: Distillation temperature
        alpha: Distillation alpha
        crystallization_weight: Weight of crystallization penalty
        output_dir: Directory to save checkpoints
        max_length: Max sequence length for tokenization

    Returns:
        trained student model
    """
    import os
    os.makedirs(output_dir, exist_ok=True)

    student = student.to(device)
    teacher = teacher.to(device)
    teacher.eval()

    optimizer = torch.optim.AdamW(student.parameters(), lr=lr)
    dataloader = DataLoader(dataset, batch_size=batch_size, shuffle=True)

    global_step = 0
    for epoch in range(epochs):
        student.train()
        epoch_loss = 0.0

        pbar = tqdm(dataloader, desc=f"Epoch {epoch+1}/{epochs}")
        for batch in pbar:
            if isinstance(batch, list):
                texts = batch
            else:
                texts = batch["text"] if "text" in batch else batch

            inputs = tokenizer(
                texts,
                return_tensors="pt",
                padding=True,
                truncation=True,
                max_length=max_length,
            ).to(device)

            input_ids = inputs.input_ids
            labels = input_ids.clone()
            labels[labels == tokenizer.pad_token_id] = -100

            # Student forward (CrystallineModel returns single tensor when labels=None)
            student_out = student(input_ids, labels=None)
            student_logits = student_out if isinstance(student_out, torch.Tensor) else student_out[0]

            with torch.no_grad():
                teacher_out = teacher(input_ids, labels=None)
                teacher_logits = teacher_out.logits if hasattr(teacher_out, 'logits') else teacher_out

            # Distillation loss
            loss = crystalline_distillation_loss(
                student_logits[:, :-1, :],
                teacher_logits[:, 1:, :],
                labels[:, 1:],
                temperature=temperature,
                alpha=alpha,
            )

            # Crystallization penalty
            if crystallization_weight > 0:
                penalty = sum(
                    crystallization_penalty(p)
                    for p in student.parameters()
                )
                loss = loss + crystallization_weight * penalty

            optimizer.zero_grad()
            loss.backward()
            torch.nn.utils.clip_grad_norm_(student.parameters(), 1.0)
            optimizer.step()

            epoch_loss += loss.item()
            global_step += 1
            pbar.set_postfix({"loss": f"{loss.item():.4f}"})

        avg_loss = epoch_loss / len(dataloader)
        print(f"Epoch {epoch+1} average loss: {avg_loss:.4f}")

        # Save checkpoint
        checkpoint_path = os.path.join(output_dir, f"checkpoint_epoch_{epoch+1}.pt")
        torch.save({
            "epoch": epoch + 1,
            "model_state_dict": student.state_dict(),
            "optimizer_state_dict": optimizer.state_dict(),
            "loss": avg_loss,
        }, checkpoint_path)
        print(f"Checkpoint saved to {checkpoint_path}")

    return student


class TextDataset(Dataset):
    """Simple text dataset for distillation."""

    def __init__(self, texts, tokenizer, max_length: int = 128):
        self.texts = texts
        self.tokenizer = tokenizer
        self.max_length = max_length

    def __len__(self):
        return len(self.texts)

    def __getitem__(self, idx):
        return self.texts[idx]


def generate_synthetic_data(
    teacher: nn.Module,
    tokenizer,
    num_samples: int = 100,
    max_length: int = 128,
    prompt: str = "Explain",
    device: str = "cuda",
) -> list[str]:
    """Generate synthetic training data from teacher model.

    Args:
        teacher: Teacher model
        tokenizer: Tokenizer
        num_samples: Number of samples to generate
        max_length: Max length per sample
        prompt: Base prompt for generation
        device: Device

    Returns:
        texts: List of generated strings
    """
    teacher.eval()
    texts = []

    with torch.no_grad():
        for i in range(num_samples):
            inputs = tokenizer(f"{prompt} the concept of {i}:", return_tensors="pt").to(device)
            outputs = teacher.generate(
                **inputs,
                max_new_tokens=max_length,
                do_sample=True,
                temperature=0.8,
                top_p=0.95,
            )
            text = tokenizer.decode(outputs[0], skip_special_tokens=True)
            texts.append(text)

    return texts
