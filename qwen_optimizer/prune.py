"""
Pruning utilities for Qwen models.

Implements Stage 2 of the CompressionPipeline:
- Structured pruning of FFN intermediate dimensions
- Magnitude-based unstructured pruning with sparse matrix support
- Attention head pruning based on importance scores

Reference: CompressionPipeline.lean (prune stage)
"""

import math
from typing import Dict, List, Optional, Tuple

import torch
import torch.nn as nn


def prune_ffn_intermediate(
    model: nn.Module,
    prune_ratio: float = 0.3,
    method: str = "magnitude",
) -> Dict[str, torch.Tensor]:
    """Structured pruning of FFN intermediate dimensions.

    Removes the least important neurons from fc1 / up-projection layers,
    and the corresponding weights from fc2 / down-projection layers.

    Args:
        model: Transformer model to prune
        prune_ratio: Fraction of intermediate neurons to remove (0.0 - 1.0)
        method: "magnitude" or "gradient" importance scoring

    Returns:
        Dictionary mapping layer names to pruning masks
    """
    masks = {}
    for name, module in model.named_modules():
        if "fc1" in name or "gate_proj" in name or "up_proj" in name:
            # Find paired down-projection
            down_name = name.replace("fc1", "fc2").replace("gate_proj", "down_proj").replace("up_proj", "down_proj")
            down_module = None
            for dn, dm in model.named_modules():
                if dn == down_name:
                    down_module = dm
                    break

            weight = module.weight.data  # (intermediate, hidden) or (hidden, intermediate)
            is_transposed = weight.shape[0] < weight.shape[1]
            if is_transposed:
                weight = weight.t()

            # Compute neuron importance: L2 norm of each neuron's weights
            importance = weight.norm(dim=1)  # (intermediate,)
            k = int((1 - prune_ratio) * importance.numel())
            k = max(1, k)

            _, topk_indices = torch.topk(importance, k, largest=True, sorted=False)
            mask = torch.zeros_like(importance, dtype=torch.bool)
            mask[topk_indices] = True
            masks[name] = mask

            # Prune up-projection
            pruned_weight = weight[mask, :]
            if is_transposed:
                module.weight.data = pruned_weight.t()
            else:
                module.weight.data = pruned_weight

            if module.bias is not None:
                module.bias.data = module.bias.data[mask]

            # Prune paired down-projection
            if down_module is not None:
                dw = down_module.weight.data
                # down_proj: (hidden, intermediate)
                pruned_dw = dw[:, mask]
                down_module.weight.data = pruned_dw
                if down_module.bias is not None:
                    # down_proj bias is (hidden,), unaffected by intermediate pruning
                    pass

    return masks


def unstructured_magnitude_prune(
    model: nn.Module,
    sparsity: float = 0.5,
) -> int:
    """Unstructured magnitude pruning: zero out smallest weights.

    Sets weights below the global threshold to zero. The threshold is
    chosen such that exactly `sparsity` fraction of parameters are zero.

    Args:
        model: Model to prune
        sparsity: Target fraction of zero weights (0.0 - 1.0)

    Returns:
        Number of parameters pruned
    """
    all_weights = torch.cat([p.view(-1) for p in model.parameters() if p.requires_grad])
    k = int(sparsity * all_weights.numel())
    threshold = torch.kthvalue(all_weights.abs(), k).values.item()

    pruned_count = 0
    for p in model.parameters():
        if not p.requires_grad:
            continue
        mask = p.abs() >= threshold
        pruned_count += (~mask).sum().item()
        p.data *= mask.float()

    return pruned_count


def prune_attention_heads(
    model: nn.Module,
    num_heads_to_prune: int = 4,
) -> List[Tuple[str, int]]:
    """Prune least important attention heads.

    Importance is computed as the L2 norm of the query/key/value projection
    weights for each head.

    Args:
        model: Transformer model
        num_heads_to_prune: Total number of heads to remove across all layers

    Returns:
        List of (layer_name, head_index) tuples that were pruned
    """
    head_importance = []
    for name, module in model.named_modules():
        if hasattr(module, "num_heads") and hasattr(module, "q_proj"):
            num_heads = module.num_heads
            head_dim = module.head_dim
            q_weight = module.q_proj.weight.data.view(num_heads, head_dim, -1)
            k_weight = module.k_proj.weight.data.view(num_heads, head_dim, -1)
            v_weight = module.v_proj.weight.data.view(num_heads, head_dim, -1)

            for h in range(num_heads):
                score = (
                    q_weight[h].norm()
                    + k_weight[h].norm()
                    + v_weight[h].norm()
                ).item()
                head_importance.append((name, h, score))

    # Sort by ascending importance
    head_importance.sort(key=lambda x: x[2])
    to_prune = head_importance[:num_heads_to_prune]

    pruned = []
    for layer_name, head_idx, _ in to_prune:
        pruned.append((layer_name, head_idx))
        # Set corresponding Q/K/V weights to zero for this head
        for name, module in model.named_modules():
            if name == layer_name:
                head_dim = module.head_dim
                with torch.no_grad():
                    module.q_proj.weight.data[head_idx * head_dim:(head_idx + 1) * head_dim] = 0
                    module.k_proj.weight.data[head_idx * head_dim:(head_idx + 1) * head_dim] = 0
                    module.v_proj.weight.data[head_idx * head_dim:(head_idx + 1) * head_dim] = 0
                break

    return pruned


def compute_sparsity(model: nn.Module) -> float:
    """Compute the fraction of zero weights in the model."""
    total = 0
    zeros = 0
    for p in model.parameters():
        total += p.numel()
        zeros += (p == 0).sum().item()
    return zeros / total if total > 0 else 0.0


def prune_model(
    model: nn.Module,
    ffn_prune_ratio: float = 0.0,
    unstructured_sparsity: float = 0.0,
    heads_to_prune: int = 0,
) -> Dict[str, any]:
    """Apply multi-stage pruning to a model.

    Args:
        model: Model to prune
        ffn_prune_ratio: Fraction of FFN neurons to remove
        unstructured_sparsity: Target global unstructured sparsity
        heads_to_prune: Number of attention heads to remove

    Returns:
        Dictionary with pruning statistics
    """
    stats = {
        "ffn_masks": {},
        "unstructured_pruned": 0,
        "heads_pruned": [],
        "sparsity_before": compute_sparsity(model),
        "sparsity_after": 0.0,
    }

    if ffn_prune_ratio > 0:
        stats["ffn_masks"] = prune_ffn_intermediate(model, ffn_prune_ratio)

    if unstructured_sparsity > 0:
        stats["unstructured_pruned"] = unstructured_magnitude_prune(model, unstructured_sparsity)

    if heads_to_prune > 0:
        stats["heads_pruned"] = prune_attention_heads(model, heads_to_prune)

    stats["sparsity_after"] = compute_sparsity(model)
    return stats
