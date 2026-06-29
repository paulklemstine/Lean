"""
Composition Theory for Set-Local Distortion of Hausdorff Dimension
==================================================================

Numerical demonstrations of the composition calculus for Hausdorff-dimension
distortion. The Lean development proves the following facts; this script
illustrates them numerically and verifies the multiplicativity laws on concrete
fractals (where the dimensions are known exactly).

Theorems illustrated
--------------------
1. AntilipschitzOnWith.comp                 antilipschitz constants multiply: K_f * K_g
2. AntilipschitzOnWith.mono                 control descends to subsets
3. antilipschitzOnWith_of_antilipschitzWith global control => local control
4. dimH_image_comp_eq_...                    composite bi-Lipschitz => dimension invariant
5. dimH_image_comp_bounds_of_biholderOn      composite bi-Holder => exponents multiply:
        dimH((g.f)(s)) <= dimH s / (r_g * r_f)
        dimH s        <= dimH((g.f)(s)) / (r_f' * r_g')

Everything is self-contained: standard library only.
"""

from __future__ import annotations

import math
from dataclasses import dataclass


# ---------------------------------------------------------------------------
# 1. Hausdorff dimension of standard self-similar fractals (closed forms)
# ---------------------------------------------------------------------------
def self_similar_dimension(num_copies: int, inverse_scale: float) -> float:
    """Hausdorff dimension of a self-similar set with `num_copies` pieces, each
    a copy scaled by 1/inverse_scale.  dim = log(N) / log(1/r) = log N / log s."""
    return math.log(num_copies) / math.log(inverse_scale)


KNOWN_FRACTALS = {
    "Cantor set": self_similar_dimension(2, 3),          # ~0.6309
    "Koch curve": self_similar_dimension(4, 3),          # ~1.2619
    "Sierpinski triangle": self_similar_dimension(3, 2), # ~1.5850
    "Sierpinski carpet": self_similar_dimension(8, 3),   # ~1.8928
    "Menger sponge": self_similar_dimension(20, 3),      # ~2.7268
}


# ---------------------------------------------------------------------------
# 2. A stage of a distortion pipeline (one set-local good map)
# ---------------------------------------------------------------------------
@dataclass(frozen=True)
class Stage:
    """A single set-local bi-Holder map.

    r_forward : Holder exponent of the map        (1 => Lipschitz)
    r_inverse : Holder exponent of its inverse    (1 => antilipschitz-with-Lip-inverse)
    K_anti    : antilipschitz constant            (only used for the bi-Lipschitz track)
    """
    r_forward: float
    r_inverse: float
    K_anti: float = 1.0

    @property
    def is_bilipschitz(self) -> bool:
        return self.r_forward == 1.0 and self.r_inverse == 1.0


# ---------------------------------------------------------------------------
# 3. Composition laws (the content of the theorems)
# ---------------------------------------------------------------------------
def compose_antilipschitz_constants(constants: list[float]) -> float:
    """AntilipschitzOnWith.comp: the composite antilipschitz constant is the
    product of the stage constants."""
    out = 1.0
    for k in constants:
        out *= k
    return out


def pipeline_exponents(stages: list[Stage]) -> tuple[float, float]:
    """Multiplicativity of Holder exponents under composition.

    Returns (R_forward, R_inverse) where
        R_forward = product of r_forward  (controls the upper dimension bound)
        R_inverse = product of r_inverse  (controls the lower dimension bound)
    """
    r_fwd = 1.0
    r_inv = 1.0
    for st in stages:
        r_fwd *= st.r_forward
        r_inv *= st.r_inverse
    return r_fwd, r_inv


def dimension_envelope(base_dim: float, stages: list[Stage]) -> tuple[float, float]:
    """Algorithm 5.1: certified [lo, hi] envelope for dimH of the final image.

    By dimH_image_comp_bounds_of_biholderOn:
        dimH(image) <= base_dim / R_forward
        base_dim    <= dimH(image) / R_inverse   <=>   dimH(image) >= base_dim * R_inverse
    """
    r_fwd, r_inv = pipeline_exponents(stages)
    hi = base_dim / r_fwd
    lo = base_dim * r_inv
    return lo, hi


# ---------------------------------------------------------------------------
# 4. Demonstrations
# ---------------------------------------------------------------------------
def demo_bilipschitz_invariance() -> None:
    print("=" * 70)
    print("DEMO 1  Composite bi-Lipschitz invariance (Theorem 4.1)")
    print("=" * 70)
    print("A pipeline of bi-Lipschitz stages leaves the dimension unchanged,")
    print("no matter how many stages or how large their constants.\n")

    pipeline = [
        Stage(r_forward=1.0, r_inverse=1.0, K_anti=3.0),
        Stage(r_forward=1.0, r_inverse=1.0, K_anti=7.0),
        Stage(r_forward=1.0, r_inverse=1.0, K_anti=2.0),
    ]
    for name, d in KNOWN_FRACTALS.items():
        lo, hi = dimension_envelope(d, pipeline)
        K = compose_antilipschitz_constants([s.K_anti for s in pipeline])
        ok = math.isclose(lo, d) and math.isclose(hi, d)
        print(f"  {name:22s}  dim={d:.4f}  ->  envelope=[{lo:.4f}, {hi:.4f}]"
              f"  (composite K={K:g})  {'OK' if ok else 'FAIL'}")
    print()


def demo_multiplied_exponents() -> None:
    print("=" * 70)
    print("DEMO 2  Composite bi-Holder distortion (Theorem 4.2)")
    print("=" * 70)
    print("Holder exponents MULTIPLY under composition.")
    print("Stage f: r_f=0.5, r_f'=0.8 ;  Stage g: r_g=0.5, r_g'=0.9\n")

    f = Stage(r_forward=0.5, r_inverse=0.8)
    g = Stage(r_forward=0.5, r_inverse=0.9)
    stages = [f, g]
    R_fwd, R_inv = pipeline_exponents(stages)
    print(f"  forward product r_g * r_f  = {g.r_forward} * {f.r_forward} = {R_fwd}")
    print(f"  inverse product r_f' * r_g'= {f.r_inverse} * {g.r_inverse} = {R_inv}\n")

    d = KNOWN_FRACTALS["Koch curve"]
    lo, hi = dimension_envelope(d, stages)
    print(f"  base set: Koch curve, dimH s = {d:.4f}")
    print(f"  guaranteed: dimH((g.f)(s)) <= {d:.4f} / {R_fwd} = {hi:.4f}")
    print(f"  guaranteed: dimH((g.f)(s)) >= {d:.4f} * {R_inv} = {lo:.4f}")
    print(f"  certified envelope: [{lo:.4f}, {hi:.4f}]\n")


def demo_consistency_limit() -> None:
    print("=" * 70)
    print("DEMO 3  Consistency: exponents -> 1 collapses to invariance (Cor 4.3)")
    print("=" * 70)
    d = KNOWN_FRACTALS["Sierpinski triangle"]
    for r in [0.5, 0.7, 0.9, 0.99, 1.0]:
        stages = [Stage(r, r), Stage(r, r)]
        lo, hi = dimension_envelope(d, stages)
        print(f"  r={r:<5}  envelope width = hi-lo = {hi - lo:8.4f}   "
              f"[{lo:.4f}, {hi:.4f}]")
    print("  As every exponent -> 1, the envelope pinches shut to the exact dimension.\n")


def demo_antilipschitz_constants() -> None:
    print("=" * 70)
    print("DEMO 4  Antilipschitz constants multiply (Theorem 3.1)")
    print("=" * 70)
    ks = [2.0, 3.5, 1.25, 4.0]
    prod = compose_antilipschitz_constants(ks)
    print(f"  stage constants: {ks}")
    print(f"  composite constant K_1*...*K_n = {prod:g}")
    print("  (the composite never crushes distances by more than this factor)\n")


def demo_long_pipeline() -> None:
    print("=" * 70)
    print("DEMO 5  A long mixed pipeline (Lipschitz + Holder stages)")
    print("=" * 70)
    stages = [
        Stage(1.0, 1.0),   # bi-Lipschitz: no effect
        Stage(0.9, 0.95),  # mild Holder
        Stage(1.0, 1.0),   # bi-Lipschitz: no effect
        Stage(0.8, 0.85),  # stronger Holder
    ]
    d = KNOWN_FRACTALS["Sierpinski carpet"]
    R_fwd, R_inv = pipeline_exponents(stages)
    lo, hi = dimension_envelope(d, stages)
    print(f"  base: Sierpinski carpet, dimH s = {d:.4f}")
    print(f"  only the Holder stages contribute: R_forward={R_fwd:.4f}, R_inverse={R_inv:.4f}")
    print(f"  certified envelope: [{lo:.4f}, {hi:.4f}]")
    print("  Bi-Lipschitz stages are transparent; Holder stages widen the envelope.\n")


def main() -> None:
    print("\nCOMPOSITION CALCULUS FOR HAUSDORFF-DIMENSION DISTORTION")
    print("Numerical companion to the Lean development.\n")
    for name, d in KNOWN_FRACTALS.items():
        print(f"  reference: dimH({name}) = {d:.6f}")
    print()
    demo_bilipschitz_invariance()
    demo_multiplied_exponents()
    demo_consistency_limit()
    demo_antilipschitz_constants()
    demo_long_pipeline()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()


"""
Visualization: how the certified Hausdorff-dimension envelope of a composition
pipeline widens as Holder exponents move away from 1 (bi-Lipschitz), and how
exponents multiply along a chain of stages.

Generates two panels:
  (left)  envelope width vs Holder exponent r for an n-stage pipeline,
  (right) cumulative forward exponent product along a fixed pipeline.

Self-contained; requires matplotlib + numpy.
"""

from __future__ import annotations

import math

import matplotlib.pyplot as plt
import numpy as np


def envelope(base_dim: float, r_forward_product: float,
             r_inverse_product: float) -> tuple[float, float]:
    """Certified [lo, hi] for dimH of the image (Theorem 4.2)."""
    return base_dim * r_inverse_product, base_dim / r_forward_product


def main() -> None:
    base_dim = math.log(3) / math.log(2)  # Sierpinski triangle ~1.585

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    # ---- Panel 1: envelope vs exponent, for several pipeline lengths ----
    rs = np.linspace(0.4, 1.0, 200)
    for n in (1, 2, 3):
        los, his = [], []
        for r in rs:
            R = r ** n  # all stages share exponent r; product is r^n
            lo, hi = envelope(base_dim, R, R)
            los.append(lo)
            his.append(hi)
        ax1.fill_between(rs, los, his, alpha=0.25, label=f"{n}-stage pipeline")
    ax1.axhline(base_dim, color="black", ls="--", lw=1, label="dimH s (invariant)")
    ax1.set_xlabel("Holder exponent r (per stage)")
    ax1.set_ylabel("certified dimension envelope")
    ax1.set_title("Envelope pinches to dimH s as r -> 1")
    ax1.legend()
    ax1.set_ylim(0, 6)

    # ---- Panel 2: multiplicativity of exponents along a chain ----
    stage_exponents = [0.9, 0.8, 0.95, 0.7, 0.85]
    cum = np.cumprod([1.0] + stage_exponents)
    ax2.plot(range(len(cum)), cum, "o-", color="crimson")
    for i, val in enumerate(cum):
        ax2.annotate(f"{val:.3f}", (i, val), textcoords="offset points",
                     xytext=(0, 8), ha="center", fontsize=8)
    ax2.set_xlabel("number of stages composed")
    ax2.set_ylabel("cumulative forward exponent product")
    ax2.set_title("Holder exponents MULTIPLY along the chain")
    ax2.set_ylim(0, 1.05)
    ax2.grid(True, alpha=0.3)

    fig.suptitle("Composition calculus for Hausdorff-dimension distortion",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("distortion_envelope.png", dpi=150)
    print("Saved distortion_envelope.png")


if __name__ == "__main__":
    main()
