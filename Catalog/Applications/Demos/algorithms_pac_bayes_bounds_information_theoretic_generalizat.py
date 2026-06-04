#!/usr/bin/env python3
"""
Algorithms for Information-Theoretic Generalization Bounds

Type-hinted implementations of the core algorithms from the theory.
"""

import math
from dataclasses import dataclass
from typing import List, Optional, Tuple


# ============================================================
# Algorithm 1: MI Generalization Bound Computation
# ============================================================

@dataclass
class MIGenBoundResult:
    """Result of computing an MI generalization bound."""
    mi_bound: float
    desc_len_bound: float
    info_density: float
    sample_complexity_for_eps: int

def compute_mi_gen_bound(
    mutual_info: float,
    desc_len: float,
    sample_size: int,
    loss_range: float = 1.0,
    target_eps: Optional[float] = None
) -> MIGenBoundResult:
    """
    Compute the MI-based generalization bound.

    Algorithm:
    1. MI bound = loss_range * sqrt(2 * I(S;W) / n)
    2. Description length bound = loss_range * sqrt(2 * L / n)
    3. Info density = I(S;W) / n
    4. Sample complexity for target eps: n >= 2 * I * loss_range^2 / eps^2

    Args:
        mutual_info: I(S;W), mutual information between data and hypothesis
        desc_len: L, description length of hypothesis in nats
        sample_size: n, number of training samples
        loss_range: Range of the loss function [0, loss_range]
        target_eps: Optional target generalization gap

    Returns:
        MIGenBoundResult with all computed quantities
    """
    assert mutual_info >= 0
    assert mutual_info <= desc_len
    assert sample_size > 0
    assert loss_range > 0

    mi_bound = loss_range * math.sqrt(2 * mutual_info / sample_size)
    dl_bound = loss_range * math.sqrt(2 * desc_len / sample_size)
    density = mutual_info / sample_size

    if target_eps and target_eps > 0:
        n_needed = math.ceil(2 * mutual_info * loss_range**2 / target_eps**2)
    else:
        n_needed = sample_size

    return MIGenBoundResult(
        mi_bound=mi_bound,
        desc_len_bound=dl_bound,
        info_density=density,
        sample_complexity_for_eps=n_needed
    )


# ============================================================
# Algorithm 2: Composite Channel Bound
# ============================================================

@dataclass
class CompositeResult:
    """Result of composite channel analysis."""
    layer_bounds: List[float]
    total_info: float
    composite_bound: float
    dominant_layer: int

def compute_composite_bound(
    layer_infos: List[float],
    sample_size: int,
    loss_range: float = 1.0
) -> CompositeResult:
    """
    Compute generalization bound for a multi-layer architecture.

    Algorithm:
    1. Total MI = sum of layer MIs (chain rule upper bound)
    2. Composite bound = loss_range * sqrt(2 * total_MI / n)
    3. Identify dominant layer (highest MI contribution)

    Args:
        layer_infos: List of per-layer mutual informations I(S; W_k | W_{k-1})
        sample_size: Number of training samples
        loss_range: Loss function range

    Returns:
        CompositeResult with per-layer and total bounds
    """
    assert all(i >= 0 for i in layer_infos)
    assert sample_size > 0
    assert loss_range > 0

    total_info = sum(layer_infos)
    composite_bound = loss_range * math.sqrt(2 * total_info / sample_size)

    # Per-layer bounds (as if each layer alone determined generalization)
    layer_bounds = [
        loss_range * math.sqrt(2 * mi / sample_size)
        for mi in layer_infos
    ]

    dominant_layer = max(range(len(layer_infos)), key=lambda i: layer_infos[i])

    return CompositeResult(
        layer_bounds=layer_bounds,
        total_info=total_info,
        composite_bound=composite_bound,
        dominant_layer=dominant_layer
    )


# ============================================================
# Algorithm 3: Information Bottleneck Optimizer
# ============================================================

@dataclass
class BottleneckResult:
    """Result of information bottleneck optimization."""
    optimal_compression: float
    gen_bound: float
    prediction_quality: float
    pareto_front: List[Tuple[float, float]]

def optimize_bottleneck(
    input_entropy: float,
    target_entropy: float,
    sample_size: int,
    loss_range: float = 1.0,
    num_points: int = 50,
    beta: float = 1.0
) -> BottleneckResult:
    """
    Find the optimal information bottleneck compression level.

    Algorithm:
    1. Sweep compression ratios from 0 to 1
    2. For each ratio r:
       - I(X;T) = r * H(X)
       - I(T;Y) = model_info(r, H(Y))
       - gen_bound = loss_range * sqrt(2 * I(X;T) / n)
       - pred_quality = I(T;Y) / H(Y)
    3. Find optimal: minimize gen_bound - beta * pred_quality
    4. Return Pareto front

    Args:
        input_entropy: H(X), entropy of input
        target_entropy: H(Y), entropy of target
        sample_size: n
        loss_range: Loss range
        num_points: Number of points in sweep
        beta: Tradeoff parameter (higher = favor prediction)

    Returns:
        BottleneckResult with optimal compression and Pareto front
    """
    pareto_front: List[Tuple[float, float]] = []
    best_score = float('inf')
    best_compression = 0.0
    best_gen = 0.0
    best_pred = 0.0

    for i in range(num_points + 1):
        ratio = i / num_points
        input_info = ratio * input_entropy
        # Model: I(T;Y) saturates as sqrt of I(X;T)
        target_info = min(target_entropy, target_entropy * math.sqrt(ratio))

        gen = loss_range * math.sqrt(2 * input_info / sample_size)
        pred = target_info / target_entropy

        pareto_front.append((gen, pred))

        score = gen - beta * pred
        if score < best_score:
            best_score = score
            best_compression = ratio
            best_gen = gen
            best_pred = pred

    return BottleneckResult(
        optimal_compression=best_compression,
        gen_bound=best_gen,
        prediction_quality=best_pred,
        pareto_front=pareto_front
    )


# ============================================================
# Algorithm 4: PAC-Bayes to MI Bridge
# ============================================================

@dataclass
class BridgeResult:
    """Result of PAC-Bayes to MI bridge computation."""
    kl_divergence: float
    mutual_info_bound: float
    pac_bayes_bound: float
    mi_bound: float
    tighter_bound: str

def pac_bayes_mi_bridge(
    kl_divergence: float,
    mutual_info: float,
    sample_size: int,
    delta: float = 0.05,
    loss_range: float = 1.0
) -> BridgeResult:
    """
    Compare PAC-Bayes and MI generalization bounds.

    The PAC-Bayes bound uses KL/(2n) under the sqrt.
    The MI bound uses 2*MI/n under the sqrt.
    When 4*MI ≤ KL + log(1/δ), the PAC-Bayes bound dominates.

    Args:
        kl_divergence: KL(Q || P), posterior-prior divergence
        mutual_info: I(S;W), mutual information
        sample_size: n
        delta: Confidence parameter
        loss_range: Loss range

    Returns:
        BridgeResult comparing both bounds
    """
    log_inv_delta = math.log(1 / delta)

    pac_bound = loss_range * math.sqrt(
        (kl_divergence + log_inv_delta) / (2 * sample_size)
    )

    mi_bound = loss_range * math.sqrt(2 * mutual_info / sample_size)

    tighter = "PAC-Bayes" if pac_bound <= mi_bound else "MI"

    return BridgeResult(
        kl_divergence=kl_divergence,
        mutual_info_bound=mutual_info,
        pac_bayes_bound=pac_bound,
        mi_bound=mi_bound,
        tighter_bound=tighter
    )


# ============================================================
# Algorithm 5: Sample Complexity Calculator
# ============================================================

def required_samples(
    mutual_info: float,
    target_eps: float,
    loss_range: float = 1.0
) -> int:
    """
    Compute the minimum number of samples needed for a target
    generalization gap.

    From the MI bound: eps = loss_range * sqrt(2 * MI / n)
    Solving: n >= 2 * MI * loss_range^2 / eps^2

    Args:
        mutual_info: I(S;W)
        target_eps: Target generalization gap
        loss_range: Loss range

    Returns:
        Minimum number of samples
    """
    assert mutual_info >= 0
    assert target_eps > 0
    assert loss_range > 0
    return math.ceil(2 * mutual_info * loss_range**2 / target_eps**2)


if __name__ == "__main__":
    # Quick test
    result = compute_mi_gen_bound(10.0, 20.0, 1000, target_eps=0.1)
    print(f"MI bound: {result.mi_bound:.4f}")
    print(f"DL bound: {result.desc_len_bound:.4f}")
    print(f"Samples for eps=0.1: {result.sample_complexity_for_eps}")

    comp = compute_composite_bound([1.0, 2.0, 3.0], 1000)
    print(f"Composite bound: {comp.composite_bound:.4f}")
    print(f"Dominant layer: {comp.dominant_layer}")

    bridge = pac_bayes_mi_bridge(5.0, 3.0, 1000)
    print(f"PAC-Bayes bound: {bridge.pac_bayes_bound:.4f}")
    print(f"MI bound: {bridge.mi_bound:.4f}")
    print(f"Tighter: {bridge.tighter_bound}")
