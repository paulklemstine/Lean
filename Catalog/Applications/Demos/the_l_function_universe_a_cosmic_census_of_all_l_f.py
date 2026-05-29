"""
applications.py — Applications of the L-Data Census Theory

Demonstrates practical applications of the countability and enumeration
theorems for finite-description L-data:

1. Searching for L-data matching specific arithmetic constraints
2. Computing density statistics for conductor-bounded families
3. Filtering for arithmetically meaningful objects (prime bad sets)
4. Cross-domain bridge: information-theoretic analysis of L-data complexity
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Iterator
from itertools import product as cartesian_product
from collections import defaultdict
import math


# ─── Self-contained definitions ────────────────────────────────────────────

@dataclass(frozen=True)
class DiscreteEulerFactor:
    coeffs: tuple[int, ...]

    @property
    def degree(self) -> int:
        return len(self.coeffs)


@dataclass(frozen=True)
class FiniteDescriptionLData:
    degree: int
    conductor: int
    root_number: int
    unramified_template: DiscreteEulerFactor
    bad_primes: tuple[int, ...]
    ramified_factors: tuple[DiscreteEulerFactor, ...]

    @property
    def num_bad_primes(self) -> int:
        return len(self.bad_primes)

    @property
    def max_bad_prime(self) -> int:
        return max(self.bad_primes) if self.bad_primes else 0

    @property
    def description_length(self) -> int:
        return self.degree + self.conductor + self.num_bad_primes + self.max_bad_prime + 1

    @property
    def arithmetic_complexity(self) -> int:
        return self.degree * (self.num_bad_primes + 1) + self.conductor

    def __repr__(self) -> str:
        return (f"L(d={self.degree},N={self.conductor},ε={self.root_number},"
                f"bad={self.bad_primes})")


def enum_factors(degree: int, cr: range) -> list[DiscreteEulerFactor]:
    if degree == 0:
        return [DiscreteEulerFactor(())]
    return [DiscreteEulerFactor(c) for c in cartesian_product(cr, repeat=degree)]


def enumerate_ldata(B: int, cr: range = range(-1, 2),
                    rns: tuple[int, ...] = (-1, 1)) -> Iterator[FiniteDescriptionLData]:
    if B < 1:
        return
    for total in range(B):
        for d in range(total + 1):
            templates = enum_factors(d, cr)
            for c in range(total - d + 1):
                for nb in range(total - d - c + 1):
                    mbp = total - d - c - nb
                    for tmpl in templates:
                        for rn in rns:
                            if nb == 0:
                                yield FiniteDescriptionLData(d, c, rn, tmpl, (), ())
                            else:
                                rf_list = enum_factors(d, cr)
                                for bpl in cartesian_product(range(mbp + 1), repeat=nb):
                                    for rf in cartesian_product(rf_list, repeat=nb):
                                        yield FiniteDescriptionLData(
                                            d, c, rn, tmpl, tuple(bpl), tuple(rf))


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0:
        return False
    for i in range(3, int(n ** 0.5) + 1, 2):
        if n % i == 0:
            return False
    return True


# ─── Application 1: Search for specific L-data ─────────────────────────────

def search_by_degree_and_conductor(
    target_degree: int,
    target_conductor: int,
    max_B: int = 8,
) -> list[FiniteDescriptionLData]:
    """Find all L-data with specific degree and conductor."""
    results = []
    for x in enumerate_ldata(max_B):
        if x.degree == target_degree and x.conductor == target_conductor:
            results.append(x)
    return results


# ─── Application 2: Density statistics ─────────────────────────────────────

def conductor_density_analysis(max_B: int = 5) -> None:
    """Analyze how L-data distribute across conductors."""
    print("\n=== Application 2: Conductor Density Analysis ===\n")
    by_cond: dict[int, int] = defaultdict(int)
    total = 0
    for x in enumerate_ldata(max_B):
        by_cond[x.conductor] += 1
        total += 1

    print(f"  Total objects (descLen ≤ {max_B}): {total}")
    print(f"  Distinct conductors: {len(by_cond)}")
    print()
    for c in sorted(by_cond):
        pct = 100 * by_cond[c] / total
        print(f"  N={c}: {by_cond[c]:5d} ({pct:5.1f}%)")


# ─── Application 3: Arithmetically meaningful filtering ─────────────────────

def filter_prime_ramification(max_B: int = 5) -> None:
    """Filter L-data to those with all bad 'primes' actually prime."""
    print("\n=== Application 3: Prime Ramification Filter ===\n")
    all_obj = list(enumerate_ldata(max_B))
    ram = [x for x in all_obj if x.num_bad_primes > 0]
    prime_ram = [x for x in ram if all(is_prime(p) for p in x.bad_primes)]

    print(f"  Total L-data: {len(all_obj)}")
    print(f"  Ramified (num_bad > 0): {len(ram)}")
    print(f"  All-prime bad sets: {len(prime_ram)}")
    if ram:
        print(f"  Prime fraction: {len(prime_ram)/len(ram):.4f}")
    print()
    print("  Examples of prime-ramified L-data:")
    for x in prime_ram[:10]:
        print(f"    {x}")


# ─── Application 4: Information-theoretic analysis ─────────────────────────

def information_complexity_analysis(max_B: int = 5) -> None:
    """Analyze the information content of L-data strata."""
    print("\n=== Application 4: Information-Theoretic Complexity ===\n")
    by_dl: dict[int, int] = defaultdict(int)
    for x in enumerate_ldata(max_B):
        by_dl[x.description_length] += 1

    print("  Description length → log2(stratum size):")
    print("  (This measures bits of information in each complexity class)")
    print()
    cumulative = 0
    for dl in sorted(by_dl):
        count = by_dl[dl]
        cumulative += count
        bits = math.log2(count) if count > 1 else 0
        cum_bits = math.log2(cumulative) if cumulative > 1 else 0
        print(f"  dL={dl}: {count:5d} objects, "
              f"log2={bits:.2f} bits, cum_log2={cum_bits:.2f}")

    print()
    print("  Key insight: The universe has a natural entropy filtration.")
    print("  Each stratum's log-size gives the information needed to specify")
    print("  an L-datum at that complexity level.")


# ─── Application 5: Degree-conductor grid ──────────────────────────────────

def degree_conductor_grid(max_B: int = 5) -> None:
    """Show the degree × conductor distribution."""
    print("\n=== Application 5: Degree × Conductor Grid ===\n")
    grid: dict[tuple[int, int], int] = defaultdict(int)
    for x in enumerate_ldata(max_B):
        grid[(x.degree, x.conductor)] += 1

    max_d = max(k[0] for k in grid) if grid else 0
    max_c = max(k[1] for k in grid) if grid else 0

    # Header
    header = "  d\\N |" + "".join(f"{c:6d}" for c in range(max_c + 1))
    print(header)
    print("  " + "-" * (len(header) - 2))
    for d in range(max_d + 1):
        row = f"  {d:3d} |"
        for c in range(max_c + 1):
            cnt = grid.get((d, c), 0)
            row += f"{cnt:6d}"
        print(row)


# ─── Main ──────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 65)
    print("  APPLICATIONS OF THE L-DATA CENSUS THEORY")
    print("=" * 65)

    # App 1
    print("\n=== Application 1: Search for degree-1, conductor-1 L-data ===\n")
    results = search_by_degree_and_conductor(1, 1, max_B=5)
    print(f"  Found {len(results)} objects with degree=1, conductor=1:")
    for x in results[:20]:
        print(f"    {x}")

    # App 2
    conductor_density_analysis(5)

    # App 3
    filter_prime_ramification(5)

    # App 4
    information_complexity_analysis(5)

    # App 5
    degree_conductor_grid(5)

    print()


"""
demo.py — Interactive Exploration of the L-Function Census

Demonstrates the enumeration, grouping, and conjecture-testing of
finite-description L-data as formalized in the Lean development.

Usage:
    python demo.py
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Iterator
from itertools import product as cartesian_product
from collections import defaultdict
import math


# ─── Inline definitions (self-contained) ───────────────────────────────────

@dataclass(frozen=True)
class DiscreteEulerFactor:
    coeffs: tuple[int, ...]

    @property
    def degree(self) -> int:
        return len(self.coeffs)

    def __repr__(self) -> str:
        if not self.coeffs:
            return "EF(1)"
        return f"EF({','.join(str(c) for c in self.coeffs)})"


@dataclass(frozen=True)
class FiniteDescriptionLData:
    degree: int
    conductor: int
    root_number: int
    unramified_template: DiscreteEulerFactor
    bad_primes: tuple[int, ...]
    ramified_factors: tuple[DiscreteEulerFactor, ...]

    @property
    def num_bad_primes(self) -> int:
        return len(self.bad_primes)

    @property
    def max_bad_prime(self) -> int:
        return max(self.bad_primes) if self.bad_primes else 0

    @property
    def description_length(self) -> int:
        return self.degree + self.conductor + self.num_bad_primes + self.max_bad_prime + 1

    @property
    def arithmetic_complexity(self) -> int:
        return self.degree * (self.num_bad_primes + 1) + self.conductor

    def __repr__(self) -> str:
        return (f"L(d={self.degree},N={self.conductor},ε={self.root_number},"
                f"bad={self.bad_primes},dL={self.description_length})")


def enum_factors(degree: int, cr: range) -> list[DiscreteEulerFactor]:
    if degree == 0:
        return [DiscreteEulerFactor(())]
    return [DiscreteEulerFactor(c) for c in cartesian_product(cr, repeat=degree)]


def enumerate_ldata(B: int, cr: range = range(-1, 2),
                    rns: tuple[int, ...] = (-1, 1)) -> Iterator[FiniteDescriptionLData]:
    if B < 1:
        return
    for total in range(B):
        for d in range(total + 1):
            templates = enum_factors(d, cr)
            for c in range(total - d + 1):
                for nb in range(total - d - c + 1):
                    mbp = total - d - c - nb
                    for tmpl in templates:
                        for rn in rns:
                            if nb == 0:
                                yield FiniteDescriptionLData(d, c, rn, tmpl, (), ())
                            else:
                                ram_factors_list = enum_factors(d, cr)
                                for bpl in cartesian_product(range(mbp + 1), repeat=nb):
                                    for rf in cartesian_product(ram_factors_list, repeat=nb):
                                        yield FiniteDescriptionLData(
                                            d, c, rn, tmpl, tuple(bpl), tuple(rf))


# ─── Demo ──────────────────────────────────────────────────────────────────

def main():
    print("=" * 70)
    print("  THE L-FUNCTION UNIVERSE: A Cosmic Census of Discrete L-Data")
    print("=" * 70)

    # Parameters
    coeff_range = range(-1, 2)  # {-1, 0, 1}
    root_numbers = (-1, 1)
    max_B = 5

    # ─── 1. Enumerate first 100 objects ────────────────────────────────────
    print("\n── First 100 L-data objects ──\n")
    all_objects: list[FiniteDescriptionLData] = []
    for i, x in enumerate(enumerate_ldata(max_B, coeff_range, root_numbers)):
        all_objects.append(x)
        if i < 100:
            print(f"  [{i:3d}] {x}")
        if len(all_objects) > 5000:
            break

    total_enum = len(all_objects)
    print(f"\n  ... Total enumerated (descLen ≤ {max_B}): {total_enum}")

    # ─── 2. Group by conductor ─────────────────────────────────────────────
    print("\n── Grouping by conductor ──\n")
    by_conductor: dict[int, int] = defaultdict(int)
    for x in all_objects:
        by_conductor[x.conductor] += 1
    for c in sorted(by_conductor):
        print(f"  Conductor {c}: {by_conductor[c]} objects")

    # ─── 3. Histogram of description length ────────────────────────────────
    print("\n── Histogram of description length ──\n")
    by_dl: dict[int, int] = defaultdict(int)
    for x in all_objects:
        by_dl[x.description_length] += 1
    cumulative = 0
    for dl in sorted(by_dl):
        cumulative += by_dl[dl]
        bar = "█" * min(by_dl[dl], 60)
        print(f"  dL={dl}: {by_dl[dl]:5d} objects (cum: {cumulative:6d}) {bar}")

    # ─── 4. Group by degree ────────────────────────────────────────────────
    print("\n── Grouping by degree ──\n")
    by_degree: dict[int, int] = defaultdict(int)
    for x in all_objects:
        by_degree[x.degree] += 1
    for d in sorted(by_degree):
        print(f"  Degree {d}: {by_degree[d]} objects")

    # ─── 5. Conjecture testing: polynomial growth ──────────────────────────
    print("\n── Conjecture Test: Description-Length Growth Rate ──\n")
    print("  Testing: Does |{x : dL(x) ≤ B}| grow polynomially in B?")
    print()
    cumulative = 0
    prev = 1
    for dl in sorted(by_dl):
        cumulative += by_dl[dl]
        ratio = cumulative / prev if prev > 0 else 0
        log_ratio = math.log2(ratio) if ratio > 1 else 0
        print(f"  B={dl}: count={cumulative:6d}, ratio={ratio:.2f}, "
              f"log2(ratio)={log_ratio:.2f}")
        prev = max(cumulative, 1)

    print("\n  Interpretation: If log2(ratio) stabilizes, growth is polynomial.")
    print("  If it increases, growth is super-polynomial (likely exponential).")

    # ─── 6. Sparsity test: fraction of 'prime-like' bad prime sets ─────────
    print("\n── Conjecture Test: Conductor-First Sparsity ──\n")
    print("  Among L-data with num_bad_primes > 0, what fraction")
    print("  have all bad 'primes' actually prime?")
    print()

    def is_prime(n: int) -> bool:
        if n < 2:
            return False
        if n < 4:
            return True
        if n % 2 == 0:
            return False
        for i in range(3, int(n ** 0.5) + 1, 2):
            if n % i == 0:
                return False
        return True

    ramified = [x for x in all_objects if x.num_bad_primes > 0]
    prime_ramified = [x for x in ramified if all(is_prime(p) for p in x.bad_primes)]
    if ramified:
        frac = len(prime_ramified) / len(ramified)
        print(f"  Total ramified: {len(ramified)}")
        print(f"  With all-prime bad sets: {len(prime_ramified)}")
        print(f"  Fraction: {frac:.4f}")
        print(f"\n  As description length grows, this fraction should decrease")
        print(f"  (primes become sparser among naturals).")
    else:
        print("  No ramified objects found at this bound.")

    # ─── 7. Summary ───────────────────────────────────────────────────────
    print("\n" + "=" * 70)
    print("  SUMMARY")
    print("=" * 70)
    print(f"\n  Universe size (descLen ≤ {max_B}): {total_enum}")
    print(f"  Distinct conductors: {len(by_conductor)}")
    print(f"  Distinct degrees: {len(by_degree)}")
    print(f"  Max description length seen: {max(by_dl) if by_dl else 0}")
    print(f"\n  Key theorem (formalized in Lean):")
    print(f"  'The universe of finite-description L-data is countable.'")
    print(f"  'For each bound B, there are finitely many L-data with dL ≤ B.'")
    print()


if __name__ == "__main__":
    main()


"""
Visualization: Complexity Strata of the L-Function Universe

This script visualizes the entropy filtration of finite-description L-data.
It shows how the number of L-data objects grows with description length,
demonstrating the finiteness theorem: each stratum {dL ≤ B} is finite,
and the growth rate reveals the combinatorial structure of the L-data cosmos.
"""

import matplotlib.pyplot as plt
import numpy as np
from dataclasses import dataclass
from itertools import product as cartesian_product
from collections import defaultdict
from typing import Iterator
import math


# ─── Self-contained L-data definitions ─────────────────────────────────────

@dataclass(frozen=True)
class DiscreteEulerFactor:
    coeffs: tuple

    @property
    def degree(self):
        return len(self.coeffs)


@dataclass(frozen=True)
class FiniteDescriptionLData:
    degree: int
    conductor: int
    root_number: int
    unramified_template: DiscreteEulerFactor
    bad_primes: tuple
    ramified_factors: tuple

    @property
    def num_bad_primes(self):
        return len(self.bad_primes)

    @property
    def max_bad_prime(self):
        return max(self.bad_primes) if self.bad_primes else 0

    @property
    def description_length(self):
        return self.degree + self.conductor + self.num_bad_primes + self.max_bad_prime + 1


def enum_factors(degree, cr):
    if degree == 0:
        return [DiscreteEulerFactor(())]
    return [DiscreteEulerFactor(c) for c in cartesian_product(cr, repeat=degree)]


def enumerate_ldata(B, cr=range(-1, 2), rns=(-1, 1)):
    if B < 1:
        return
    for total in range(B):
        for d in range(total + 1):
            templates = enum_factors(d, cr)
            for c in range(total - d + 1):
                for nb in range(total - d - c + 1):
                    mbp = total - d - c - nb
                    for tmpl in templates:
                        for rn in rns:
                            if nb == 0:
                                yield FiniteDescriptionLData(d, c, rn, tmpl, (), ())
                            else:
                                rf_list = enum_factors(d, cr)
                                for bpl in cartesian_product(range(mbp + 1), repeat=nb):
                                    for rf in cartesian_product(rf_list, repeat=nb):
                                        yield FiniteDescriptionLData(
                                            d, c, rn, tmpl, tuple(bpl), tuple(rf))


# ─── Compute data ──────────────────────────────────────────────────────────

max_B = 6
by_dl = defaultdict(int)
by_deg_dl = defaultdict(lambda: defaultdict(int))

for x in enumerate_ldata(max_B):
    dl = x.description_length
    by_dl[dl] += 1
    by_deg_dl[x.degree][dl] += 1

dls = sorted(by_dl.keys())
counts = [by_dl[dl] for dl in dls]
cumulative = np.cumsum(counts)
log_counts = [math.log2(c) if c > 0 else 0 for c in counts]
log_cum = [math.log2(c) if c > 0 else 0 for c in cumulative]

# ─── Create figure ─────────────────────────────────────────────────────────

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("The L-Function Universe: Complexity Strata",
             fontsize=16, fontweight='bold', y=0.98)

# Panel 1: Stratum sizes (bar chart)
ax1 = axes[0, 0]
colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(dls)))
ax1.bar(dls, counts, color=colors, edgecolor='black', linewidth=0.5)
ax1.set_xlabel("Description Length (B)", fontsize=12)
ax1.set_ylabel("Number of L-data", fontsize=12)
ax1.set_title("Stratum Sizes: |{x : dL(x) = B}|", fontsize=13)
ax1.set_yscale('log')
for i, (dl, cnt) in enumerate(zip(dls, counts)):
    ax1.text(dl, cnt * 1.2, str(cnt), ha='center', va='bottom', fontsize=8)

# Panel 2: Cumulative growth (log scale)
ax2 = axes[0, 1]
ax2.plot(dls, cumulative, 'o-', color='darkblue', linewidth=2, markersize=6)
ax2.fill_between(dls, 1, cumulative, alpha=0.15, color='blue')
ax2.set_xlabel("Description Length Bound (B)", fontsize=12)
ax2.set_ylabel("Cumulative Count", fontsize=12)
ax2.set_title("Cumulative: |{x : dL(x) ≤ B}|", fontsize=13)
ax2.set_yscale('log')
ax2.grid(True, alpha=0.3)

# Panel 3: log₂ of stratum size (information content)
ax3 = axes[1, 0]
ax3.plot(dls, log_counts, 's-', color='crimson', linewidth=2, markersize=7)
ax3.plot(dls, log_cum, 'D-', color='darkgreen', linewidth=2, markersize=6, alpha=0.7)
ax3.set_xlabel("Description Length (B)", fontsize=12)
ax3.set_ylabel("log₂(count)", fontsize=12)
ax3.set_title("Information Content per Stratum", fontsize=13)
ax3.legend(["log₂(stratum size)", "log₂(cumulative)"], fontsize=10)
ax3.grid(True, alpha=0.3)

# Panel 4: Stacked by degree
ax4 = axes[1, 1]
degrees = sorted(by_deg_dl.keys())
bottom = np.zeros(len(dls))
cmap = plt.cm.Set2
for i, deg in enumerate(degrees):
    vals = [by_deg_dl[deg].get(dl, 0) for dl in dls]
    ax4.bar(dls, vals, bottom=bottom, label=f"deg={deg}",
            color=cmap(i / max(len(degrees), 1)), edgecolor='black', linewidth=0.3)
    bottom += np.array(vals)
ax4.set_xlabel("Description Length (B)", fontsize=12)
ax4.set_ylabel("Count", fontsize=12)
ax4.set_title("Strata Decomposed by Degree", fontsize=13)
ax4.legend(fontsize=9, loc='upper left')

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig("viz_complexity_strata.png", dpi=150, bbox_inches='tight')
print("Saved viz_complexity_strata.png")


"""
Visualization: Conductor Landscape of the L-Function Universe

This script creates a heatmap showing the distribution of L-data objects
across the degree × conductor plane, revealing the geometric structure
of the arithmetic L-data cosmos. The density pattern reflects how
combinatorial complexity concentrates in different regions of parameter space.
"""

import matplotlib.pyplot as plt
import numpy as np
from dataclasses import dataclass
from itertools import product as cartesian_product
from collections import defaultdict


# ─── Self-contained L-data definitions ─────────────────────────────────────

@dataclass(frozen=True)
class DiscreteEulerFactor:
    coeffs: tuple

    @property
    def degree(self):
        return len(self.coeffs)


@dataclass(frozen=True)
class FiniteDescriptionLData:
    degree: int
    conductor: int
    root_number: int
    unramified_template: DiscreteEulerFactor
    bad_primes: tuple
    ramified_factors: tuple

    @property
    def num_bad_primes(self):
        return len(self.bad_primes)

    @property
    def max_bad_prime(self):
        return max(self.bad_primes) if self.bad_primes else 0

    @property
    def description_length(self):
        return self.degree + self.conductor + self.num_bad_primes + self.max_bad_prime + 1

    @property
    def arithmetic_complexity(self):
        return self.degree * (self.num_bad_primes + 1) + self.conductor


def enum_factors(degree, cr):
    if degree == 0:
        return [DiscreteEulerFactor(())]
    return [DiscreteEulerFactor(c) for c in cartesian_product(cr, repeat=degree)]


def enumerate_ldata(B, cr=range(-1, 2), rns=(-1, 1)):
    if B < 1:
        return
    for total in range(B):
        for d in range(total + 1):
            templates = enum_factors(d, cr)
            for c in range(total - d + 1):
                for nb in range(total - d - c + 1):
                    mbp = total - d - c - nb
                    for tmpl in templates:
                        for rn in rns:
                            if nb == 0:
                                yield FiniteDescriptionLData(d, c, rn, tmpl, (), ())
                            else:
                                rf_list = enum_factors(d, cr)
                                for bpl in cartesian_product(range(mbp + 1), repeat=nb):
                                    for rf in cartesian_product(rf_list, repeat=nb):
                                        yield FiniteDescriptionLData(
                                            d, c, rn, tmpl, tuple(bpl), tuple(rf))


# ─── Compute data ──────────────────────────────────────────────────────────

max_B = 6
grid = defaultdict(int)
ac_grid = defaultdict(int)

for x in enumerate_ldata(max_B):
    grid[(x.degree, x.conductor)] += 1
    ac_grid[(x.degree, x.num_bad_primes)] += 1

max_d = max(k[0] for k in grid) if grid else 0
max_c = max(k[1] for k in grid) if grid else 0
max_nb = max(k[1] for k in ac_grid) if ac_grid else 0

# Build matrices
mat1 = np.zeros((max_d + 1, max_c + 1))
for (d, c), cnt in grid.items():
    mat1[d, c] = cnt

mat2 = np.zeros((max_d + 1, max_nb + 1))
for (d, nb), cnt in ac_grid.items():
    mat2[d, nb] = cnt

# ─── Create figure ─────────────────────────────────────────────────────────

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))
fig.suptitle("The Conductor Landscape of L-Data",
             fontsize=16, fontweight='bold', y=1.02)

# Heatmap 1: Degree × Conductor
log_mat1 = np.log10(mat1 + 1)
im1 = ax1.imshow(log_mat1, aspect='auto', cmap='YlOrRd',
                 origin='lower', interpolation='nearest')
ax1.set_xlabel("Conductor (N)", fontsize=12)
ax1.set_ylabel("Degree (d)", fontsize=12)
ax1.set_title("log₁₀(count + 1) by Degree × Conductor", fontsize=13)
cbar1 = plt.colorbar(im1, ax=ax1, shrink=0.8)
cbar1.set_label("log₁₀(count + 1)")

# Annotate cells
for d in range(max_d + 1):
    for c in range(max_c + 1):
        val = int(mat1[d, c])
        if val > 0:
            color = 'white' if log_mat1[d, c] > log_mat1.max() * 0.6 else 'black'
            ax1.text(c, d, str(val), ha='center', va='center',
                     fontsize=7, color=color, fontweight='bold')

# Heatmap 2: Degree × Number of Bad Primes
log_mat2 = np.log10(mat2 + 1)
im2 = ax2.imshow(log_mat2, aspect='auto', cmap='YlGnBu',
                 origin='lower', interpolation='nearest')
ax2.set_xlabel("Number of Bad Primes", fontsize=12)
ax2.set_ylabel("Degree (d)", fontsize=12)
ax2.set_title("log₁₀(count + 1) by Degree × #Bad Primes", fontsize=13)
cbar2 = plt.colorbar(im2, ax=ax2, shrink=0.8)
cbar2.set_label("log₁₀(count + 1)")

for d in range(max_d + 1):
    for nb in range(max_nb + 1):
        val = int(mat2[d, nb])
        if val > 0:
            color = 'white' if log_mat2[d, nb] > log_mat2.max() * 0.6 else 'black'
            ax2.text(nb, d, str(val), ha='center', va='center',
                     fontsize=7, color=color, fontweight='bold')

plt.tight_layout()
plt.savefig("viz_conductor_landscape.png", dpi=150, bbox_inches='tight')
print("Saved viz_conductor_landscape.png")


"""
Visualization: Growth Conjecture Test for L-Data Census

Tests the falsifiable conjecture that the number of finite-description
L-data with description length ≤ B grows at most polynomially in B
for fixed coefficient alphabets. Plots the growth curve alongside
polynomial and exponential reference curves for comparison.
"""

import matplotlib.pyplot as plt
import numpy as np
from dataclasses import dataclass
from itertools import product as cartesian_product
from collections import defaultdict
import math


# ─── Self-contained L-data definitions ─────────────────────────────────────

@dataclass(frozen=True)
class DiscreteEulerFactor:
    coeffs: tuple

    @property
    def degree(self):
        return len(self.coeffs)


@dataclass(frozen=True)
class FiniteDescriptionLData:
    degree: int
    conductor: int
    root_number: int
    unramified_template: DiscreteEulerFactor
    bad_primes: tuple
    ramified_factors: tuple

    @property
    def num_bad_primes(self):
        return len(self.bad_primes)

    @property
    def max_bad_prime(self):
        return max(self.bad_primes) if self.bad_primes else 0

    @property
    def description_length(self):
        return self.degree + self.conductor + self.num_bad_primes + self.max_bad_prime + 1


def enum_factors(degree, cr):
    if degree == 0:
        return [DiscreteEulerFactor(())]
    return [DiscreteEulerFactor(c) for c in cartesian_product(cr, repeat=degree)]


def enumerate_ldata(B, cr=range(-1, 2), rns=(-1, 1)):
    if B < 1:
        return
    for total in range(B):
        for d in range(total + 1):
            templates = enum_factors(d, cr)
            for c in range(total - d + 1):
                for nb in range(total - d - c + 1):
                    mbp = total - d - c - nb
                    for tmpl in templates:
                        for rn in rns:
                            if nb == 0:
                                yield FiniteDescriptionLData(d, c, rn, tmpl, (), ())
                            else:
                                rf_list = enum_factors(d, cr)
                                for bpl in cartesian_product(range(mbp + 1), repeat=nb):
                                    for rf in cartesian_product(rf_list, repeat=nb):
                                        yield FiniteDescriptionLData(
                                            d, c, rn, tmpl, tuple(bpl), tuple(rf))


# ─── Compute growth data for multiple coefficient ranges ───────────────────

configs = [
    ("α = {0}", range(0, 1), (1,)),
    ("α = {0, 1}", range(0, 2), (-1, 1)),
    ("α = {-1, 0, 1}", range(-1, 2), (-1, 1)),
]

max_B = 7
results = {}

for label, cr, rns in configs:
    by_dl = defaultdict(int)
    for x in enumerate_ldata(max_B, cr, rns):
        by_dl[x.description_length] += 1

    dls = sorted(by_dl.keys())
    cumulative = []
    running = 0
    for dl in range(1, max_B + 1):
        running += by_dl.get(dl, 0)
        cumulative.append(running)
    results[label] = cumulative

# ─── Create figure ─────────────────────────────────────────────────────────

fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle("Growth Conjecture: Is |{x : dL(x) ≤ B}| Polynomial in B?",
             fontsize=16, fontweight='bold', y=1.02)

Bs = np.arange(1, max_B + 1)

# Panel 1: Raw growth curves
ax1 = axes[0]
markers = ['o-', 's-', 'D-']
colors = ['#2196F3', '#FF9800', '#E91E63']
for i, (label, cum) in enumerate(results.items()):
    ax1.plot(Bs, cum, markers[i], color=colors[i], linewidth=2,
             markersize=7, label=label)
ax1.set_xlabel("Description Length Bound (B)", fontsize=12)
ax1.set_ylabel("Cumulative Count", fontsize=12)
ax1.set_title("Growth Curves", fontsize=13)
ax1.legend(fontsize=10)
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Panel 2: Log-log plot with polynomial fit
ax2 = axes[1]
main_label = "α = {-1, 0, 1}"
cum = results[main_label]
log_B = np.log(Bs.astype(float))
log_cum = np.array([math.log(max(c, 1)) for c in cum])

# Fit polynomial (in log-log)
coeffs = np.polyfit(log_B[1:], log_cum[1:], 1)
fit_line = np.polyval(coeffs, log_B)

ax2.plot(log_B, log_cum, 'D-', color='#E91E63', linewidth=2,
         markersize=7, label='Data')
ax2.plot(log_B, fit_line, '--', color='gray', linewidth=2,
         label=f'Fit: slope={coeffs[0]:.2f}')
ax2.set_xlabel("log(B)", fontsize=12)
ax2.set_ylabel("log(cumulative count)", fontsize=12)
ax2.set_title(f"Log-Log Plot ({main_label})", fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.text(0.05, 0.95, f"Power law exponent ≈ {coeffs[0]:.2f}",
         transform=ax2.transAxes, fontsize=11, va='top',
         bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

# Panel 3: Successive ratios
ax3 = axes[2]
for i, (label, cum) in enumerate(results.items()):
    ratios = []
    for j in range(1, len(cum)):
        if cum[j-1] > 0:
            ratios.append(cum[j] / cum[j-1])
        else:
            ratios.append(0)
    ax3.plot(Bs[1:], ratios, markers[i], color=colors[i], linewidth=2,
             markersize=7, label=label)

ax3.axhline(y=1, color='gray', linestyle=':', alpha=0.5)
ax3.set_xlabel("Description Length Bound (B)", fontsize=12)
ax3.set_ylabel("Ratio: count(B) / count(B-1)", fontsize=12)
ax3.set_title("Successive Growth Ratios", fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)
ax3.text(0.05, 0.95,
         "Stabilizing ratio → polynomial growth\n"
         "Increasing ratio → super-polynomial",
         transform=ax3.transAxes, fontsize=9, va='top',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.5))

plt.tight_layout()
plt.savefig("viz_growth_conjecture.png", dpi=150, bbox_inches='tight')
print("Saved viz_growth_conjecture.png")
