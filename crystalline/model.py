"""Crystalline model: full transformer-like architecture using tropical primitives.

Supports both standard blocks and DeltaNet blocks, plus a dedicated MoE variant
for Qwen3.6-style architectures.
"""

from dataclasses import dataclass
from typing import Optional, Dict, Tuple

import torch
import torch.nn as nn
import torch.nn.functional as F

from .deltanet import CrystallineDeltaLayer
from .moe import CrystallineMoELayer
from .crystallize import crystallize_module


@dataclass
class CrystallineConfig:
    """Configuration for a Crystalline model."""

    vocab_size: int = 32000
    d_model: int = 512
    num_layers: int = 6
    num_heads: int = 8
    d_ff: int = 1024
    max_seq_len: int = 2048
    dropout: float = 0.1
    use_delta_net: bool = False
    num_experts: int = 8
    top_k: int = 2
    tie_weights: bool = True


class CrystallineBlock(nn.Module):
    """A single Crystalline transformer block.

    Can use either standard attention or DeltaNet depending on config.
    """

    def __init__(self, config: CrystallineConfig):
        super().__init__()
        self.config = config

        if config.use_delta_net:
            self.attn = CrystallineDeltaLayer(
                d_model=config.d_model,
                num_heads=config.num_heads,
                dropout=config.dropout,
            )
        else:
            # Fallback to standard multi-head attention for Qwen2.5 baseline
            self.attn = nn.MultiheadAttention(
                embed_dim=config.d_model,
                num_heads=config.num_heads,
                dropout=config.dropout,
                batch_first=True,
            )

        self.norm1 = nn.LayerNorm(config.d_model)
        self.norm2 = nn.LayerNorm(config.d_model)

        if config.num_experts > 1:
            self.ffn = CrystallineMoELayer(
                d_model=config.d_model,
                d_ff=config.d_ff,
                num_experts=config.num_experts,
                top_k=config.top_k,
                dropout=config.dropout,
            )
        else:
            self.ffn = nn.Sequential(
                nn.Linear(config.d_model, config.d_ff),
                nn.GELU(),
                nn.Dropout(config.dropout),
                nn.Linear(config.d_ff, config.d_model),
                nn.Dropout(config.dropout),
            )

    def forward(self, x: torch.Tensor, mask: Optional[torch.Tensor] = None) -> torch.Tensor:
        if self.config.use_delta_net:
            attn_out = self.attn(x, mask=mask)
        else:
            # Standard attention with causal mask
            if mask is None:
                T = x.size(1)
                mask = torch.triu(torch.ones(T, T, device=x.device), diagonal=1).bool()
            attn_out, _ = self.attn(x, x, x, attn_mask=mask, need_weights=False)

        x = self.norm1(x + attn_out)
        ffn_out = self.ffn(x)
        x = self.norm2(x + ffn_out)
        return x


class CrystallineModel(nn.Module):
    """Full Crystalline language model.

    Args:
        config: CrystallineConfig
    """

    def __init__(self, config: CrystallineConfig):
        super().__init__()
        self.config = config

        self.token_emb = nn.Embedding(config.vocab_size, config.d_model)
        self.pos_emb = nn.Embedding(config.max_seq_len, config.d_model)

        self.blocks = nn.ModuleList([
            CrystallineBlock(config) for _ in range(config.num_layers)
        ])

        self.norm = nn.LayerNorm(config.d_model)
        self.head = nn.Linear(config.d_model, config.vocab_size, bias=False)

        if config.tie_weights:
            self.head.weight = self.token_emb.weight

        self.dropout = nn.Dropout(config.dropout)
        self._init_weights()

    def _init_weights(self):
        for module in self.modules():
            if isinstance(module, nn.Linear):
                nn.init.normal_(module.weight, mean=0.0, std=0.02)
                if module.bias is not None:
                    nn.init.zeros_(module.bias)
            elif isinstance(module, nn.Embedding):
                nn.init.normal_(module.weight, mean=0.0, std=0.02)
            elif isinstance(module, nn.LayerNorm):
                nn.init.ones_(module.weight)
                nn.init.zeros_(module.bias)

    def forward(
        self,
        input_ids: torch.Tensor,
        labels: Optional[torch.Tensor] = None,
    ) -> torch.Tensor:
        """Forward pass.

        Args:
            input_ids: (batch, seq_len)
            labels: Optional (batch, seq_len) for loss computation

        Returns:
            logits: (batch, seq_len, vocab_size)
            loss: Optional cross-entropy loss if labels provided
        """
        B, T = input_ids.shape

        positions = torch.arange(T, device=input_ids.device).unsqueeze(0)
        x = self.token_emb(input_ids) + self.pos_emb(positions)
        x = self.dropout(x)

        # Causal mask
        causal_mask = torch.triu(torch.ones(T, T, device=x.device), diagonal=1).bool()

        for block in self.blocks:
            x = block(x, mask=causal_mask)

        x = self.norm(x)
        logits = self.head(x)

        if labels is not None:
            loss = F.cross_entropy(
                logits.view(-1, logits.size(-1)),
                labels.view(-1),
                ignore_index=-100,
            )
            return logits, loss

        return logits

    def crystallize(self) -> None:
        """Crystallize all weights to {-1, 0, 1}."""
        crystallize_module(self)

    def count_multiplications(self) -> int:
        """Count floating-point multiplications in a forward pass.

        Returns 0 if the model is fully crystallized and uses only tropical ops.
        For now, returns the count of standard PyTorch multiplications.
        """
        count = 0
        for module in self.modules():
            if isinstance(module, nn.Linear):
                # matmul: in_features * out_features per token
                # We can't know exact count without input shape; return parameter count
                count += module.weight.numel()
            elif isinstance(module, nn.Embedding):
                count += module.weight.numel()
        return count

    def generate(
        self,
        input_ids: torch.Tensor,
        max_new_tokens: int = 50,
        temperature: float = 1.0,
        top_k: int = 0,
    ) -> torch.Tensor:
        """Greedy/top-k generation.

        Args:
            input_ids: (batch, seq_len)
            max_new_tokens: Number of tokens to generate
            temperature: Sampling temperature
            top_k: If > 0, limit to top-k tokens

        Returns:
            output_ids: (batch, seq_len + max_new_tokens)
        """
        self.eval()
        for _ in range(max_new_tokens):
            logits = self.forward(input_ids)
            next_logits = logits[:, -1, :] / temperature

            if top_k > 0:
                v, _ = torch.topk(next_logits, top_k)
                next_logits[next_logits < v[:, [-1]]] = float('-inf')

            probs = F.softmax(next_logits, dim=-1)
            next_token = torch.multinomial(probs, num_samples=1)
            input_ids = torch.cat([input_ids, next_token], dim=1)

        return input_ids


class CrystallineMoEModel(CrystallineModel):
    """Crystalline model with explicit MoE support and monitoring.

    Designed for Qwen3.6-style architectures with:
    - Tropical DeltaNet attention blocks
    - Mixture-of-Experts FFN layers
    - Shared + routed expert pattern
    - Expert offloading simulation
    - Load balancing metrics

    Args:
        config: CrystallineConfig (num_experts > 1 required)
    """

    def __init__(self, config: CrystallineConfig):
        if config.num_experts <= 1:
            raise ValueError("CrystallineMoEModel requires num_experts > 1")
        super().__init__(config)
        self.expert_load_history: list[Dict[int, int]] = []

    def forward(
        self,
        input_ids: torch.Tensor,
        labels: Optional[torch.Tensor] = None,
    ) -> torch.Tensor:
        """Forward pass with expert load tracking."""
        B, T = input_ids.shape

        positions = torch.arange(T, device=input_ids.device).unsqueeze(0)
        x = self.token_emb(input_ids) + self.pos_emb(positions)
        x = self.dropout(x)

        causal_mask = torch.triu(torch.ones(T, T, device=x.device), diagonal=1).bool()

        # Track expert loads per block
        for block in self.blocks:
            x = block(x, mask=causal_mask)
            if isinstance(block.ffn, CrystallineMoELayer):
                # Capture routing decisions for monitoring
                with torch.no_grad():
                    indices, _ = block.ffn.router(x)
                    flat_indices = indices.view(-1).tolist()
                    load = {e: flat_indices.count(e) for e in range(self.config.num_experts)}
                    self.expert_load_history.append(load)

        x = self.norm(x)
        logits = self.head(x)

        if labels is not None:
            loss = F.cross_entropy(
                logits.view(-1, logits.size(-1)),
                labels.view(-1),
                ignore_index=-100,
            )
            return logits, loss

        return logits

    def get_expert_load_distribution(self) -> Optional[Dict[int, float]]:
        """Return the average expert load distribution over all tracked steps.

        Returns:
            dict mapping expert index -> average load fraction,
            or None if no history.
        """
        if not self.expert_load_history:
            return None

        total_tokens = sum(sum(load.values()) for load in self.expert_load_history)
        if total_tokens == 0:
            return None

        avg_load = {e: 0.0 for e in range(self.config.num_experts)}
        for load in self.expert_load_history:
            for e, count in load.items():
                avg_load[e] += count / total_tokens

        return avg_load

    def compute_load_balancing_loss(self) -> torch.Tensor:
        """Auxiliary load balancing loss to encourage uniform expert usage.

        Returns:
            Scalar loss penalizing skewed expert loads.
        """
        if not self.expert_load_history:
            return torch.tensor(0.0)

        # Average load per expert
        loads = self.get_expert_load_distribution()
        if loads is None:
            return torch.tensor(0.0)

        values = torch.tensor(list(loads.values()), dtype=torch.float32)
        target = torch.ones_like(values) / self.config.num_experts
        return F.mse_loss(values, target)

    def simulate_expert_offloading(
        self,
        num_experts: int = 256,
        active_experts: int = 8,
        vram_per_expert_mb: float = 60.0,
    ) -> Dict[str, float]:
        """Simulate VRAM savings from expert offloading.

        Reference: Qwen3.6-35B-A3B has 256 experts, 8 active per token.

        Args:
            num_experts: Total number of experts
            active_experts: Number active per token
            vram_per_expert_mb: Approximate VRAM per expert in MB

        Returns:
            Simulation metrics dict
        """
        total_expert_vram = num_experts * vram_per_expert_mb
        active_vram = active_experts * vram_per_expert_mb
        offloaded = total_expert_vram - active_vram
        return {
            "total_experts": num_experts,
            "active_experts": active_experts,
            "total_expert_vram_mb": total_expert_vram,
            "active_vram_mb": active_vram,
            "offloaded_vram_mb": offloaded,
            "offload_ratio": offloaded / total_expert_vram,
        }

    @staticmethod
    def from_qwen3_6_config(
        vocab_size: int = 151936,
        d_model: int = 512,
        num_layers: int = 6,
        num_heads: int = 8,
        d_ff: int = 1024,
        num_experts: int = 8,
        top_k: int = 2,
    ) -> "CrystallineMoEModel":
        """Factory method to create a CrystallineMoEModel sized for Colab T4.

        Uses smaller dimensions than the real Qwen3.6 but preserves the MoE + DeltaNet
        architecture pattern.
        """
        config = CrystallineConfig(
            vocab_size=vocab_size,
            d_model=d_model,
            num_layers=num_layers,
            num_heads=num_heads,
            d_ff=d_ff,
            max_seq_len=2048,
            dropout=0.1,
            use_delta_net=True,
            num_experts=num_experts,
            top_k=top_k,
        )
        return CrystallineMoEModel(config)
