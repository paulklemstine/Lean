#!/usr/bin/env python3
"""
Information-Theoretic Generalization Bounds: Interactive Demo

Demonstrates the core results:
1. Compression → Information → Generalization chain
2. Sample complexity scaling
3. Information bottleneck tradeoff
4. Channel capacity uniform bounds
"""

import math

# ============================================================
# Core structures
# ============================================================

class InformationChannel:
    """An information channel modeling a learning algorithm."""
    def __init__(self, mutual_info: float, desc_len: float,
                 sample_size: int, loss_range: float = 1.0,
                 emp_risk: float = 0.0):
        assert mutual_info >= 0, "Mutual information must be nonneg"
        assert mutual_info <= desc_len, "MI must be ≤ description length"
        assert sample_size > 0, "Sample size must be positive"
        assert loss_range > 0, "Loss range must be positive"
        self.mutual_info = mutual_info
        self.desc_len = desc_len
        self.sample_size = sample_size
        self.loss_range = loss_range
        self.emp_risk = emp_risk

    def mi_gen_bound(self) -> float:
        """Xu-Raginsky style MI generalization bound."""
        return self.loss_range * math.sqrt(2 * self.mutual_info / self.sample_size)

    def desc_len_gen_bound(self) -> float:
        """Description length generalization bound."""
        return self.loss_range * math.sqrt(2 * self.desc_len / self.sample_size)

    def info_density(self) -> float:
        """Information per sample."""
        return self.mutual_info / self.sample_size


class CompositeChannel:
    """Multi-layer learning channel."""
    def __init__(self, layer_infos: list, sample_size: int, loss_range: float = 1.0):
        self.layer_infos = layer_infos
        self.total_info = sum(layer_infos)
        self.sample_size = sample_size
        self.loss_range = loss_range

    def gen_bound(self) -> float:
        return self.loss_range * math.sqrt(2 * self.total_info / self.sample_size)


class InformationBottleneck:
    """Information bottleneck: tradeoff between compression and prediction."""
    def __init__(self, input_info: float, target_info: float,
                 input_entropy: float, sample_size: int, loss_range: float = 1.0):
        self.input_info = input_info
        self.target_info = target_info
        self.input_entropy = input_entropy
        self.sample_size = sample_size
        self.loss_range = loss_range

    def gen_bound(self) -> float:
        return self.loss_range * math.sqrt(2 * self.input_info / self.sample_size)


# ============================================================
# Demo 1: The Compression-Information-Generalization Chain
# ============================================================

def demo_chain():
    print("=" * 60)
    print("Demo 1: Compression → Information → Generalization")
    print("=" * 60)
    print()

    n = 1000
    print(f"Sample size n = {n}")
    print(f"{'Desc Len (L)':>14} {'MI (I≤L)':>10} {'MI Bound':>10} {'DL Bound':>10} {'MI ≤ DL?':>10}")
    print("-" * 60)

    for desc_len in [1, 5, 10, 50, 100, 500]:
        for mi_frac in [0.1, 0.5, 1.0]:
            mi = desc_len * mi_frac
            ch = InformationChannel(mi, desc_len, n)
            mi_b = ch.mi_gen_bound()
            dl_b = ch.desc_len_gen_bound()
            check = "✓" if mi_b <= dl_b + 1e-10 else "✗"
            print(f"{desc_len:>14} {mi:>10.1f} {mi_b:>10.4f} {dl_b:>10.4f} {check:>10}")
    print()


# ============================================================
# Demo 2: Sample Complexity Scaling
# ============================================================

def demo_sample_scaling():
    print("=" * 60)
    print("Demo 2: Sample Complexity — Bound scales as 1/√n")
    print("=" * 60)
    print()

    mi = 10.0
    desc_len = 20.0
    print(f"Mutual information I = {mi}, Description length L = {desc_len}")
    print(f"{'n':>10} {'MI Bound':>12} {'Bound·√n':>12} {'Ratio to prev':>15}")
    print("-" * 55)

    prev_bound = None
    for n in [100, 400, 1600, 6400, 25600]:
        ch = InformationChannel(mi, desc_len, n)
        bound = ch.mi_gen_bound()
        scaled = bound * math.sqrt(n)
        ratio = f"{prev_bound / bound:.4f}" if prev_bound else "—"
        print(f"{n:>10} {bound:>12.6f} {scaled:>12.6f} {ratio:>15}")
        prev_bound = bound

    print()
    print("Note: Bound·√n ≈ constant (confirms 1/√n scaling)")
    print("Note: Quadrupling n halves the bound (ratio ≈ 2.0)")
    print()


# ============================================================
# Demo 3: Information Bottleneck Tradeoff
# ============================================================

def demo_bottleneck():
    print("=" * 60)
    print("Demo 3: Information Bottleneck Tradeoff")
    print("=" * 60)
    print()

    input_entropy = 100.0
    n = 1000
    print(f"Input entropy H(X) = {input_entropy}, n = {n}")
    print(f"{'I(X;T)':>10} {'I(T;Y)':>10} {'Gen Bound':>12} {'Pred Quality':>14}")
    print("-" * 50)

    for compression_ratio in [0.01, 0.05, 0.1, 0.2, 0.5, 0.8, 1.0]:
        input_info = input_entropy * compression_ratio
        # Assume I(T;Y) grows sublinearly with I(X;T)
        target_info = min(10.0, input_info * 0.8)
        ib = InformationBottleneck(input_info, target_info, input_entropy, n)
        gen = ib.gen_bound()
        pred = target_info / 10.0  # normalized prediction quality
        print(f"{input_info:>10.1f} {target_info:>10.1f} {gen:>12.4f} {pred:>14.4f}")

    print()
    print("Insight: More compression → better generalization but worse prediction")
    print()


# ============================================================
# Demo 4: Separation — High desc length, low MI
# ============================================================

def demo_separation():
    print("=" * 60)
    print("Demo 4: Separation — High Description Length, Low MI")
    print("=" * 60)
    print()

    n = 1000
    print(f"n = {n}")
    print(f"{'Desc Len':>10} {'MI':>10} {'MI Bound':>12} {'DL Bound':>12}")
    print("-" * 50)

    for desc_len, mi in [(10, 10), (100, 10), (1000, 10), (10000, 10),
                          (100000, 10), (1000000, 1)]:
        ch = InformationChannel(mi, desc_len, n)
        print(f"{desc_len:>10} {mi:>10} {ch.mi_gen_bound():>12.4f} {ch.desc_len_gen_bound():>12.4f}")

    print()
    print("Insight: MI bound remains tight regardless of description length!")
    print("This is the 'lossy compression' insight formalized.")
    print()


# ============================================================
# Demo 5: Composite Channel — Layer-wise Decomposition
# ============================================================

def demo_composite():
    print("=" * 60)
    print("Demo 5: Composite Channel — Multi-Layer Bounds")
    print("=" * 60)
    print()

    n = 1000
    print(f"n = {n}")
    print(f"{'Layers':>8} {'Layer MIs':>30} {'Total MI':>10} {'Gen Bound':>12}")
    print("-" * 65)

    configs = [
        [5.0],
        [2.0, 3.0],
        [1.0, 1.5, 2.5],
        [0.5, 1.0, 1.0, 1.5, 1.0],
        [0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3],
    ]

    for layers in configs:
        cc = CompositeChannel(layers, n)
        layer_str = ", ".join(f"{l:.1f}" for l in layers)
        print(f"{len(layers):>8} {layer_str:>30} {cc.total_info:>10.1f} {cc.gen_bound():>12.4f}")

    print()


if __name__ == "__main__":
    demo_chain()
    demo_sample_scaling()
    demo_bottleneck()
    demo_separation()
    demo_composite()
    print("All demos completed successfully!")


#!/usr/bin/env python3
"""
Visualization: Information-Theoretic Generalization Bounds

Produces three key plots:
1. The compression-information-generalization hierarchy
2. Sample complexity scaling (1/sqrt(n))
3. Information bottleneck Pareto front
"""

import math

def generate_data_hierarchy():
    """Generate data for the MI vs DL bound comparison."""
    ns = list(range(100, 10001, 100))
    mi = 10.0
    desc_len = 50.0

    mi_bounds = [math.sqrt(2 * mi / n) for n in ns]
    dl_bounds = [math.sqrt(2 * desc_len / n) for n in ns]
    return ns, mi_bounds, dl_bounds

def generate_data_scaling():
    """Generate data for sample complexity scaling."""
    ns = list(range(50, 5001, 50))
    mi_values = [1.0, 5.0, 10.0, 50.0]

    results = {}
    for mi in mi_values:
        bounds = [math.sqrt(2 * mi / n) for n in ns]
        results[mi] = bounds
    return ns, results

def generate_data_bottleneck():
    """Generate Pareto front data."""
    input_entropy = 100.0
    target_entropy = 10.0
    n = 1000

    ratios = [i / 100 for i in range(1, 101)]
    gen_bounds = []
    pred_qualities = []

    for r in ratios:
        input_info = r * input_entropy
        target_info = min(target_entropy, target_entropy * math.sqrt(r))
        gen = math.sqrt(2 * input_info / n)
        pred = target_info / target_entropy
        gen_bounds.append(gen)
        pred_qualities.append(pred)

    return gen_bounds, pred_qualities

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt

    # Plot 1: Hierarchy
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    ns, mi_bounds, dl_bounds = generate_data_hierarchy()
    axes[0].plot(ns, mi_bounds, 'b-', linewidth=2, label='MI Bound (I=10)')
    axes[0].plot(ns, dl_bounds, 'r--', linewidth=2, label='DL Bound (L=50)')
    axes[0].fill_between(ns, mi_bounds, dl_bounds, alpha=0.1, color='green')
    axes[0].set_xlabel('Sample Size n', fontsize=12)
    axes[0].set_ylabel('Generalization Bound', fontsize=12)
    axes[0].set_title('Compression → Information → Generalization', fontsize=13)
    axes[0].legend(fontsize=11)
    axes[0].grid(True, alpha=0.3)

    # Plot 2: Scaling
    ns2, results = generate_data_scaling()
    colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728']
    for (mi, bounds), c in zip(results.items(), colors):
        axes[1].plot(ns2, bounds, color=c, linewidth=2, label=f'I={mi}')
    axes[1].set_xlabel('Sample Size n', fontsize=12)
    axes[1].set_ylabel('Generalization Bound', fontsize=12)
    axes[1].set_title('1/√n Scaling of MI Bound', fontsize=13)
    axes[1].legend(fontsize=11)
    axes[1].grid(True, alpha=0.3)

    # Plot 3: Bottleneck
    gen_bounds, pred_qualities = generate_data_bottleneck()
    axes[2].plot(gen_bounds, pred_qualities, 'purple', linewidth=2)
    axes[2].scatter([gen_bounds[9]], [pred_qualities[9]], c='red', s=100, zorder=5,
                     label='Optimal tradeoff')
    axes[2].set_xlabel('Generalization Bound (↓ better)', fontsize=12)
    axes[2].set_ylabel('Prediction Quality (↑ better)', fontsize=12)
    axes[2].set_title('Information Bottleneck Pareto Front', fontsize=13)
    axes[2].legend(fontsize=11)
    axes[2].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('info_gen_bounds.png', dpi=150, bbox_inches='tight')
    print("Saved: info_gen_bounds.png")

except ImportError:
    print("matplotlib not available, printing data instead")
    ns, mi_bounds, dl_bounds = generate_data_hierarchy()
    print(f"Sample sizes: {ns[:5]}...")
    print(f"MI bounds: {[f'{b:.4f}' for b in mi_bounds[:5]]}...")
    print(f"DL bounds: {[f'{b:.4f}' for b in dl_bounds[:5]]}...")
