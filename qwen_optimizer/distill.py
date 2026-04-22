"""Knowledge distillation pipeline for compressing large models into smaller students.

Inspired by DistillationLoss.lean:
    L = (1-α) * L_CE + α * T² * L_KL
"""

import torch
import torch.nn.functional as F
from torch.utils.data import DataLoader, Dataset
from transformers import AutoModelForCausalLM, AutoTokenizer
from typing import Optional, List


class SyntheticDataset(Dataset):
    """A simple dataset that yields (input_ids, labels) tensors."""

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


def distillation_loss(
    student_logits: torch.Tensor,
    teacher_logits: torch.Tensor,
    labels: torch.Tensor,
    temperature: float = 2.0,
    alpha: float = 0.5,
) -> torch.Tensor:
    """Compute the combined distillation loss.

    Args:
        student_logits: logits from the student model
        teacher_logits: logits from the teacher model
        labels: ground-truth token ids
        temperature: softmax temperature for soft targets
        alpha: weight balancing hard CE and soft KL (0 = pure CE, 1 = pure KL)

    Returns:
        Scalar loss tensor.
    """
    # Hard cross-entropy on student outputs
    ce_loss = F.cross_entropy(
        student_logits.view(-1, student_logits.size(-1)),
        labels.view(-1),
        ignore_index=-100,
    )

    # Soft KL divergence
    student_soft = F.log_softmax(student_logits / temperature, dim=-1)
    teacher_soft = F.softmax(teacher_logits / temperature, dim=-1)
    kl_loss = F.kl_div(
        student_soft.view(-1, student_logits.size(-1)),
        teacher_soft.view(-1, teacher_logits.size(-1)),
        reduction="batchmean",
    ) * (temperature ** 2)

    return (1 - alpha) * ce_loss + alpha * kl_loss


class DistillationPipeline:
    """Orchestrates teacher-student distillation."""

    def __init__(
        self,
        teacher: AutoModelForCausalLM,
        student: AutoModelForCausalLM,
        tokenizer: AutoTokenizer,
        temperature: float = 2.0,
        alpha: float = 0.5,
        device: str = "cuda",
    ):
        self.teacher = teacher.to(device)
        self.student = student.to(device)
        self.tokenizer = tokenizer
        self.temperature = temperature
        self.alpha = alpha
        self.device = device

        self.teacher.eval()

    def train_step(
        self,
        input_ids: torch.Tensor,
        attention_mask: torch.Tensor,
        optimizer: torch.optim.Optimizer,
    ) -> float:
        """Run one training step and return the loss value."""
        input_ids = input_ids.to(self.device)
        attention_mask = attention_mask.to(self.device)

        with torch.no_grad():
            teacher_out = self.teacher(
                input_ids=input_ids,
                attention_mask=attention_mask,
            )

        student_out = self.student(
            input_ids=input_ids,
            attention_mask=attention_mask,
        )

        loss = distillation_loss(
            student_out.logits,
            teacher_out.logits,
            input_ids,  # use input as labels for autoregressive LM
            temperature=self.temperature,
            alpha=self.alpha,
        )

        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        return loss.item()

    def distill(
        self,
        dataset: SyntheticDataset,
        epochs: int = 1,
        batch_size: int = 2,
        lr: float = 5e-5,
    ) -> List[float]:
        """Run the full distillation loop."""
        loader = DataLoader(dataset, batch_size=batch_size, shuffle=True)
        optimizer = torch.optim.AdamW(self.student.parameters(), lr=lr)

        losses = []
        for epoch in range(epochs):
            epoch_loss = 0.0
            for input_ids, attention_mask in loader:
                loss = self.train_step(input_ids, attention_mask, optimizer)
                epoch_loss += loss
            avg = epoch_loss / len(loader)
            losses.append(avg)
            print(f"Epoch {epoch + 1}/{epochs} — loss: {avg:.4f}")

        return losses
