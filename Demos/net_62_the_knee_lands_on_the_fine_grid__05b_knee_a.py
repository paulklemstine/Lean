"""Assemble PACKAGE.json from the prose deliverables, demo, widgets and figures.

Run:  python3 build_package.py
"""

from __future__ import annotations

import json
import pathlib
from typing import Any, Dict, List

ROOT = pathlib.Path(__file__).resolve().parent


def load(name: str) -> str:
    return (ROOT / name).read_text(encoding="utf-8")


# ---------------------------------------------------------------------------
# Algorithms
# ---------------------------------------------------------------------------

ALGORITHMS: List[Dict[str, str]] = [
    {
        "name": "Grid Reading Operator: Rounding a Threshold Up to the Nearest Sweep Point",
        "description": (
            "Computes read_G(k), the least point of a sweep grid G that is greater than or "
            "equal to k. By the Measurement Theorem this single operator is the whole content "
            "of a grid measurement: sweeping a nondecreasing profile f against a gate tau over "
            "G returns exactly read_G(k*), where k* is the true crossing point. For the "
            "arithmetic grid of step d the reading is d*ceil(k/d), computable in O(1) integer "
            "operations; for the doubling grid it is 2^ceil(log2 k), computable in O(log k) bit "
            "operations (or one leading-zero-count instruction). The operator is a closure "
            "operator on the natural numbers: inflationary, monotone and idempotent, with fixed "
            "points exactly the grid points. The uniqueness theorem says no other read-out with "
            "those four properties exists, so any 'smarter' extraction of the knee from grid data "
            "must abandon one of them."
        ),
        "pseudocode": (
            "function READ_ARITHMETIC(d, k):\n"
            "    require d >= 1\n"
            "    if k <= 0: return 0\n"
            "    return d * ceil(k / d)            # least multiple of d that is >= k\n"
            "\n"
            "function READ_DYADIC(k):\n"
            "    if k <= 1: return 1\n"
            "    e <- 0\n"
            "    while 2^e < k:                    # e ends at ceil(log2 k)\n"
            "        e <- e + 1\n"
            "    return 2^e\n"
            "\n"
            "function IS_EXACT(grid, k):\n"
            "    # exactness criteria, no sweep required\n"
            "    if grid is arithmetic with step d: return (d divides k)\n"
            "    if grid is dyadic:                 return (binary digit sum of k equals 1)\n"
            "\n"
            "function OVERSTATEMENT(grid, k):\n"
            "    return READ(grid, k) - k          # 0 iff k lies on the grid"
        ),
        "code": (
            "from typing import List\n\n\n"
            "def read_arith(d: int, k: int) -> int:\n"
            '    """Least multiple of d that is >= k."""\n'
            "    if d <= 0:\n"
            '        raise ValueError("step must be positive")\n'
            "    if k <= 0:\n"
            "        return 0\n"
            "    return d * ((k + d - 1) // d)\n\n\n"
            "def read_dyad(k: int) -> int:\n"
            '    """Least power of two that is >= k, i.e. 2 ** ceil(log2 k)."""\n'
            "    if k <= 1:\n"
            "        return 1\n"
            "    e = 0\n"
            "    while (1 << e) < k:\n"
            "        e += 1\n"
            "    return 1 << e\n\n\n"
            "def resolves_arith(d: int, k: int) -> bool:\n"
            '    """A step-d sweep reports k exactly iff d divides k."""\n'
            "    return k % d == 0\n\n\n"
            "def resolves_dyad(k: int) -> bool:\n"
            '    """A doubling sweep reports k exactly iff k has binary weight one."""\n'
            '    return bin(k).count("1") == 1\n\n\n'
            "def overstatement(read_value: int, k: int) -> int:\n"
            '    """How many budgets the sweep adds to the truth."""\n'
            "    return read_value - k\n"
        ),
    },
    {
        "name": "Monotone Sweep-and-Read: Logarithmic Extraction of the Reported Knee",
        "description": (
            "Given an oracle for a nondecreasing profile f, a gate tau, and a finite sweep set "
            "S = {g_1 < ... < g_r}, returns the least swept budget clearing the gate. The naive "
            "scan costs r oracle calls; because f is nondecreasing, the predicate f(g) >= tau is "
            "monotone along S, so binary search returns the identical answer in ceil(log2 r) "
            "calls. This matters when an oracle call is an expensive model evaluation. The "
            "Measurement Theorem guarantees the returned value equals read_S(k*) regardless of "
            "which search order is used, so the result is harness-independent: for the "
            "five-point table with gate 0.98 every nondecreasing profile reproducing the measured "
            "values returns 20."
        ),
        "pseudocode": (
            "function SWEEP_AND_READ(f, tau, S):\n"
            "    sort S increasingly as g[1] < g[2] < ... < g[r]\n"
            "    # invariant: f(g[lo]) < tau  and  f(g[hi]) >= tau\n"
            "    if f(g[r]) < tau: fail 'gate never cleared on this sweep'\n"
            "    lo <- 0; hi <- r                  # index 0 denotes a virtual failing point\n"
            "    while hi - lo > 1:\n"
            "        mid <- floor((lo + hi) / 2)\n"
            "        if f(g[mid]) >= tau: hi <- mid\n"
            "        else:                lo <- mid\n"
            "    return g[hi]                      # = read_S(k*), the reported knee"
        ),
        "code": (
            "from fractions import Fraction\n"
            "from typing import Callable, Sequence\n\n\n"
            "def sweep_and_read(\n"
            "    f: Callable[[int], Fraction], tau: Fraction, sweep: Sequence[int]\n"
            ") -> int:\n"
            '    """Least swept budget clearing the gate, found in ceil(log2 r) oracle calls."""\n'
            "    pts = sorted(sweep)\n"
            "    if not pts or f(pts[-1]) < tau:\n"
            '        raise ValueError("gate not cleared at any swept budget")\n'
            "    lo, hi = -1, len(pts) - 1\n"
            "    while hi - lo > 1:\n"
            "        mid = (lo + hi) // 2\n"
            "        if f(pts[mid]) >= tau:\n"
            "            hi = mid\n"
            "        else:\n"
            "            lo = mid\n"
            "    return pts[hi]\n"
        ),
    },
    {
        "name": "Complete Bracket Certificate for a Swept Threshold",
        "description": (
            "Converts a sweep into the strongest inference the data licenses. If g_i is the first "
            "swept point clearing the gate and g_{i-1} the last one failing it, then the true knee "
            "k* satisfies g_{i-1} < k* <= g_i, and every integer in that half-open interval is "
            "realised by some nondecreasing profile reproducing all measured values (build the "
            "staircase that holds the last failing value until t and then jumps to the first "
            "passing value). The certificate is therefore sound and complete. Reporting a point "
            "value instead of a bracket is the source of over-claiming: for the five-point table "
            "the bracket is (12, 20], which contains 16, so the datum cannot separate a knee of 16 "
            "from a knee of 20. Cost: O(1) after the sweep."
        ),
        "pseudocode": (
            "function BRACKET_CERTIFICATE(f, tau, S):\n"
            "    sort S increasingly as g[1] < ... < g[r]\n"
            "    i <- least index with f(g[i]) >= tau        # exists, else no certificate\n"
            "    low  <- (i = 1) ? 0 : g[i-1]                # last failing swept point\n"
            "    high <- g[i]                                # reported knee = read_S(k*)\n"
            "    candidates <- { t : low < t <= high }       # all knees consistent with data\n"
            "    return (low, high, candidates)\n"
            "\n"
            "function IS_CHAIN_STRICTNESS_CERTIFIED(bracket_a, bracket_b):\n"
            "    # can we conclude k*_a < k*_b from two brackets (lo_a,hi_a], (lo_b,hi_b]?\n"
            "    return hi_a <= lo_b"
        ),
        "code": (
            "from fractions import Fraction\n"
            "from typing import Callable, List, Sequence, Tuple\n\n\n"
            "def bracket_certificate(\n"
            "    f: Callable[[int], Fraction], tau: Fraction, sweep: Sequence[int]\n"
            ") -> Tuple[int, int, List[int]]:\n"
            '    """Return (last failing point, reported knee, all consistent true knees)."""\n'
            "    pts = sorted(sweep)\n"
            "    for i, g in enumerate(pts):\n"
            "        if f(g) >= tau:\n"
            "            low = 0 if i == 0 else pts[i - 1]\n"
            "            return low, g, list(range(low + 1, g + 1))\n"
            '    raise ValueError("gate not cleared at any swept budget")\n\n\n'
            "def strictness_certified(\n"
            "    bracket_a: Tuple[int, int], bracket_b: Tuple[int, int]\n"
            ") -> bool:\n"
            '    """Do two brackets (lo, hi] force k*_a < k*_b?"""\n'
            "    return bracket_a[1] <= bracket_b[0]\n"
        ),
    },
    {
        "name": "Greatest-Common-Divisor Design of a Chain-Resolving Sweep",
        "description": (
            "Solves the experiment-design problem: given a hypothesised chain of knees "
            "K = {k_1 < ... < k_r} inside a window [1, N], produce the cheapest arithmetic sweep "
            "that reports every member of K exactly. Since a step-d sweep resolves k iff d divides "
            "k, it resolves all of K iff d divides gcd(K); hence the coarsest adequate step is "
            "exactly gcd(K), and the resulting sweep has floor(N / gcd K) points. For "
            "K = {16, 20, 24} the gcd is 4, so the step-4 grid is the unique coarsest arithmetic "
            "sweep able to see the whole chain -- the choice is forced, not lucky. The Euclidean "
            "algorithm makes this O(r log max K). The routine also reports which members a "
            "doubling sweep could resolve (those of binary weight one) and how many distinct "
            "verdicts a doubling sweep can emit over the window (at most ceil(log2 N) + 1), which "
            "bounds the number of strict increases such a sweep can ever certify."
        ),
        "pseudocode": (
            "function DESIGN_SWEEP(K, N):\n"
            "    d <- 0\n"
            "    for k in K: d <- gcd(d, k)              # Euclid, O(|K| log max K)\n"
            "    sweep <- { d, 2d, 3d, ... } intersect (0, N]\n"
            "    cost  <- floor(N / d)\n"
            "\n"
            "    dyadic_resolvable <- { k in K : binary digit sum of k = 1 }\n"
            "    dyadic_verdicts   <- ceil(log2 N) + 1\n"
            "    certifiable_increases <- (number of distinct octaves met by K) - 1\n"
            "\n"
            "    return (d, sweep, cost, dyadic_resolvable, dyadic_verdicts,\n"
            "            certifiable_increases)"
        ),
        "code": (
            "from math import gcd\n"
            "from typing import Dict, Iterable, List\n\n\n"
            "def design_sweep(chain: Iterable[int], window: int) -> Dict[str, object]:\n"
            '    """Coarsest arithmetic sweep resolving every knee of the chain, plus\n'
            '    a comparison with what a doubling sweep could have certified."""\n'
            "    ks: List[int] = sorted(chain)\n"
            "    step = 0\n"
            "    for k in ks:\n"
            "        step = gcd(step, k)\n"
            "    sweep = list(range(step, window + 1, step)) if step else []\n"
            "    octaves = {k.bit_length() for k in ks}\n"
            "    return {\n"
            '        "step": step,\n'
            '        "sweep": sweep,\n'
            '        "cost": len(sweep),\n'
            '        "dyadic_resolvable": [k for k in ks if bin(k).count("1") == 1],\n'
            '        "dyadic_verdicts": (window - 1).bit_length() + 1,\n'
            '        "certifiable_strict_increases": max(len(octaves) - 1, 0),\n'
            "    }\n"
        ),
    },
]

# ---------------------------------------------------------------------------
# Visualizations
# ---------------------------------------------------------------------------

VIZ_STAIRCASE = r'''"""Figure 1: the reading operator as a staircase, fine grid versus doubling grid.

Plots read_G(k) against k for the step-4 arithmetic grid and the dyadic grid over
[1, 64], shades the overstatement read_G(k) - k, and marks the three budgets of the
chain 16 < 20 < 24 whose dyadic image collapses to 16, 32, 32.
"""

from typing import List

import matplotlib.pyplot as plt


def read_arith(d: int, k: int) -> int:
    return d * ((k + d - 1) // d)


def read_dyad(k: int) -> int:
    e = 0
    while (1 << e) < k:
        e += 1
    return 1 << e


def main() -> None:
    ks: List[int] = list(range(1, 65))
    fine = [read_arith(4, k) for k in ks]
    coarse = [read_dyad(k) for k in ks]

    fig, axes = plt.subplots(1, 2, figsize=(13, 5.2), sharey=True)

    for ax, vals, title, colour in (
        (axes[0], fine, "step-4 arithmetic grid", "#1f77b4"),
        (axes[1], coarse, "doubling grid (powers of two)", "#d62728"),
    ):
        ax.step(ks, vals, where="post", color=colour, lw=2, label=r"$\mathrm{read}_G(k)$")
        ax.plot(ks, ks, color="0.35", ls="--", lw=1.2, label=r"truth $k$")
        ax.fill_between(ks, ks, vals, step="post", color=colour, alpha=0.15,
                        label="overstatement")
        ax.set_title(title)
        ax.set_xlabel("true knee $k$")
        ax.grid(alpha=0.25)
        ax.legend(loc="upper left", frameon=False)

    axes[0].set_ylabel("reported budget")

    for k, style in ((16, "o"), (20, "s"), (24, "^")):
        axes[0].plot([k], [read_arith(4, k)], style, color="black", ms=7, zorder=5)
        axes[1].plot([k], [read_dyad(k)], style, color="black", ms=7, zorder=5)
    axes[1].annotate("20 and 24 collapse to 32", xy=(22, 32), xytext=(30, 20),
                     arrowprops=dict(arrowstyle="->", color="black"), fontsize=10)

    fig.suptitle("A measurement is the grid-rounding of the truth", fontsize=13)
    fig.tight_layout()
    fig.savefig("fig_reading_staircase.png", dpi=160)
    print("wrote fig_reading_staircase.png")


if __name__ == "__main__":
    main()
'''

VIZ_RESOLUTION = r'''"""Figure 2: resolution and verdict counting, arithmetic versus doubling sweeps.

Left panel: the number of budgets in (0, N] that each sweep resolves exactly --
floor(N/d) for a step-d sweep (a positive proportion 1/d) against at most
log2(N) + 1 for a doubling sweep (a vanishing proportion).  Right panel: the size of
the doubling sweep's entire output alphabet, ceil(log2 N) + 1, which caps the number
of distinct verdicts it can ever return and therefore forces plateaus in long chains.
"""

from typing import List

import matplotlib.pyplot as plt


def resolved_arith_count(d: int, n: int) -> int:
    return n // d


def resolved_dyad_count(n: int) -> int:
    return sum(1 for k in range(1, n + 1) if bin(k).count("1") == 1)


def read_dyad(k: int) -> int:
    e = 0
    while (1 << e) < k:
        e += 1
    return 1 << e


def dyad_verdict_count(n: int) -> int:
    return len({read_dyad(k) for k in range(1, n + 1)})


def main() -> None:
    ns: List[int] = [2 ** m for m in range(2, 15)]

    fig, axes = plt.subplots(1, 2, figsize=(13, 5))

    axes[0].loglog(ns, [resolved_arith_count(4, n) for n in ns], "o-",
                   label="step-4 sweep:  $\\lfloor N/4\\rfloor$")
    axes[0].loglog(ns, [resolved_arith_count(8, n) for n in ns], "s-",
                   label="step-8 sweep:  $\\lfloor N/8\\rfloor$")
    axes[0].loglog(ns, [resolved_dyad_count(n) for n in ns], "^-",
                   label="doubling sweep:  $\\leq \\log_2 N + 1$")
    axes[0].axvline(32, color="0.6", ls=":", lw=1.4)
    axes[0].annotate("fine grid overtakes\nfrom $N=32$", xy=(32, 8), xytext=(60, 3),
                     arrowprops=dict(arrowstyle="->", color="0.4"), fontsize=9)
    axes[0].set_xlabel("window size $N$")
    axes[0].set_ylabel("budgets resolved exactly")
    axes[0].set_title("Resolution: positive versus vanishing proportion")
    axes[0].grid(alpha=0.3, which="both")
    axes[0].legend(frameon=False)

    axes[1].semilogx(ns, [dyad_verdict_count(n) for n in ns], "o-", color="#d62728",
                     label="distinct verdicts a doubling sweep can emit")
    axes[1].semilogx(ns, [8 for _ in ns], "--", color="0.4",
                     label="an 8-cell chain to be certified")
    axes[1].set_xlabel("window size $N$")
    axes[1].set_ylabel("number of distinct reported values")
    axes[1].set_title("Verdict bound: plateaus can be forced by counting")
    axes[1].grid(alpha=0.3, which="both")
    axes[1].legend(frameon=False)

    fig.tight_layout()
    fig.savefig("fig_resolution_counting.png", dpi=160)
    print("wrote fig_resolution_counting.png")


if __name__ == "__main__":
    main()
'''

VIZ_BRACKET = r'''"""Figure 3: the five-point table, the forced reading, and the hole at 16.

Draws the measured retained-mass points against the gate 0.98, overlays the family of
staircase profiles consistent with the table (one for each candidate true knee in the
bracket (12, 20]), and shades the bracket itself.  The picture makes the logical
situation visible: every curve passes through all five measured points and every one
of them is reported as 20 by the sweep, yet their true crossing points fill the whole
interval from 13 to 20 -- including 16, the value reported at the neighbouring
context length.
"""

from typing import Dict, List

import matplotlib.pyplot as plt

GATE: float = 0.98
TABLE: Dict[int, float] = {4: 0.8940, 8: 0.9520, 12: 0.9662, 20: 0.9803, 24: 0.9851}


def witness(t: int, k: int) -> float:
    if k < 4:
        return 0.86
    if k < 8:
        return 0.8940
    if k < 12:
        return 0.9520
    if k < t:
        return 0.9662
    if k < 24:
        return 0.9803
    return 0.9851


def main() -> None:
    ks: List[int] = list(range(1, 29))
    fig, ax = plt.subplots(figsize=(11, 6))

    cmap = plt.get_cmap("viridis")
    for i, t in enumerate(range(13, 21)):
        ax.step(ks, [witness(t, k) for k in ks], where="post",
                color=cmap(i / 7.0), lw=1.6, alpha=0.9,
                label=f"true knee $k^*={t}$")

    ax.axhline(GATE, color="crimson", lw=2, ls="--", label="gate $0.98$")
    ax.axvspan(12.02, 20, color="orange", alpha=0.15)
    ax.annotate("bracket $(12,\\,20]$: every value here is consistent",
                xy=(16, 0.905), ha="center", fontsize=10)
    ax.axvline(16, color="black", ls=":", lw=1.6)
    ax.annotate("16 was never measured", xy=(16, 0.995), xytext=(4.5, 0.997),
                arrowprops=dict(arrowstyle="->", color="black"), fontsize=10)

    ax.plot(list(TABLE), list(TABLE.values()), "ko", ms=9, zorder=6,
            label="measured points")
    for k, v in TABLE.items():
        ax.annotate(f"{v:.4f}", xy=(k, v), xytext=(k - 1.0, v + 0.004), fontsize=9)

    ax.set_xlabel("attention budget $k$ (number of retained keys)")
    ax.set_ylabel("retained attention mass")
    ax.set_title("Five numbers force the reading 20 but pin the knee only to $(12, 20]$")
    ax.set_ylim(0.855, 1.005)
    ax.grid(alpha=0.25)
    ax.legend(loc="lower right", fontsize=8, ncol=2, frameon=False)

    fig.tight_layout()
    fig.savefig("fig_bracket_witnesses.png", dpi=160)
    print("wrote fig_bracket_witnesses.png")


if __name__ == "__main__":
    main()
'''

VISUALIZATIONS: List[Dict[str, str]] = [
    {
        "name": "The Reading Operator as a Staircase: Fine Grid versus Doubling Grid",
        "description": (
            "Side-by-side staircase plots of read_G(k) against the true knee k over [1, 64] for "
            "the step-4 arithmetic grid and the dyadic grid, with the overstatement "
            "read_G(k) - k shaded. The dyadic panel shows the octave collapse directly: the chain "
            "16 < 20 < 24 has image 16, 32, 32, so the strict increase between the second and "
            "third cell is invisible to a doubling sweep. The staircase form also displays the "
            "closure-operator structure -- the graph never dips below the diagonal (inflationary), "
            "never decreases (monotone), and is flat between consecutive grid points (idempotent "
            "on its image)."
        ),
        "code": VIZ_STAIRCASE,
    },
    {
        "name": "Resolution and Verdict Counting: Positive Proportion versus Vanishing Proportion",
        "description": (
            "A log-log comparison of how many budgets in (0, N] each sweep family can report "
            "exactly: floor(N/d) for a step-d arithmetic sweep against at most log2(N) + 1 for a "
            "doubling sweep, with the crossover at N = 32 marked. The second panel plots the "
            "doubling sweep's entire output alphabet, ceil(log2 N) + 1, against the length of a "
            "chain one might wish to certify, making visible the counting obstruction: a chain "
            "longer than the alphabet must contain repeated reported values, so some of its "
            "plateaus are artifacts of the ruler rather than facts about the system."
        ),
        "code": VIZ_RESOLUTION,
    },
    {
        "name": "The Bracket and the Hole: Eight Profiles That Fit the Same Five Numbers",
        "description": (
            "Plots the five measured retained-mass values against the gate 0.98 together with the "
            "eight staircase profiles whose true knees are 13, 14, ..., 20. Every profile passes "
            "through all five measured points, and every one of them is reported as 20 by the "
            "sweep, yet their true crossing points fill the whole bracket (12, 20]. The vertical "
            "line at 16 -- the budget that was never measured, and the value reported at the "
            "neighbouring context length -- shows exactly why the data certifies '20 keys suffice' "
            "but not 'the cross-context chain is strictly increasing'."
        ),
        "code": VIZ_BRACKET,
    },
]

# ---------------------------------------------------------------------------
# Interactive widgets
# ---------------------------------------------------------------------------

WIDGET_RULER = r"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1"/>
<title>The Ruler Simulator — grid readings of a hidden knee</title>
<style>
  :root { --ink:#12203a; --paper:#f7f9fc; --fine:#1f77b4; --coarse:#d62728; --gold:#e8a33d; }
  body { margin:0; padding:24px; background:var(--paper); color:var(--ink);
         font-family: "Iowan Old Style", Georgia, "Times New Roman", serif; }
  .wrap { max-width: 980px; margin: 0 auto; }
  h1 { font-size: 25px; margin: 0 0 6px; letter-spacing:.2px; }
  p.sub { margin:0 0 20px; color:#4a5b78; font-size:15px; }
  .panel { background:#fff; border:1px solid #dde4ee; border-radius:12px;
           padding:18px 20px; margin-bottom:18px; box-shadow:0 1px 3px rgba(20,40,80,.06); }
  label { font-size:14px; font-weight:600; }
  input[type=range] { width:100%; }
  .row { display:flex; gap:22px; flex-wrap:wrap; align-items:center; }
  .col { flex:1 1 260px; }
  canvas { width:100%; height:230px; display:block; }
  table { border-collapse:collapse; width:100%; font-size:14px; margin-top:6px; }
  th,td { text-align:left; padding:7px 9px; border-bottom:1px solid #e6ecf5; }
  th { font-variant: small-caps; letter-spacing:.5px; color:#4a5b78; }
  code, .mono { font-family: "SF Mono", Menlo, Consolas, monospace; font-size:13.5px; }
  .fine { color:var(--fine); font-weight:700; }
  .coarse { color:var(--coarse); font-weight:700; }
  .verdict { font-size:15.5px; padding:12px 14px; border-radius:9px; background:#fff8ec;
             border:1px solid #f0dcb8; }
  .bits span { display:inline-block; width:19px; text-align:center; border-radius:4px;
               margin-right:2px; padding:2px 0; background:#eef3fa; }
  .bits span.one { background:var(--gold); color:#fff; font-weight:700; }
</style>
</head>
<body>
<div class="wrap">
  <h1>The Ruler Simulator</h1>
  <p class="sub">A hidden monotone profile crosses its gate at some true budget <span class="mono">k*</span>.
  You never see <span class="mono">k*</span>; you only see what a ruler reports. Move the slider and watch
  the two rulers disagree — predictably.</p>

  <div class="panel">
    <div class="row">
      <div class="col">
        <label for="kstar">True knee <span class="mono">k*</span> = <span id="kval" class="mono">20</span></label>
        <input id="kstar" type="range" min="1" max="64" value="20"/>
      </div>
      <div class="col">
        <label for="step">Fine sweep step <span class="mono">d</span> = <span id="dval" class="mono">4</span></label>
        <input id="step" type="range" min="1" max="12" value="4"/>
      </div>
    </div>
    <canvas id="ruler" width="1900" height="460"></canvas>
  </div>

  <div class="panel">
    <table>
      <tr><th>Ruler</th><th>Marks</th><th>Reported budget</th><th>Overstatement</th><th>Exact?</th></tr>
      <tr>
        <td class="fine">step-<span id="d1" class="mono">4</span> arithmetic</td>
        <td class="mono" id="fineMarks"></td>
        <td class="mono fine" id="fineRead"></td>
        <td class="mono" id="fineOver"></td>
        <td id="fineExact"></td>
      </tr>
      <tr>
        <td class="coarse">doubling</td>
        <td class="mono">1, 2, 4, 8, 16, 32, 64, …</td>
        <td class="mono coarse" id="coarseRead"></td>
        <td class="mono" id="coarseOver"></td>
        <td id="coarseExact"></td>
      </tr>
    </table>
    <p style="font-size:14px;margin:14px 0 4px;">Binary expansion of <span class="mono">k*</span>
      (digit sum <span class="mono" id="wt"></span>):</p>
    <div class="bits" id="bits"></div>
  </div>

  <div class="panel verdict" id="verdict"></div>

  <div class="panel">
    <p style="font-size:14px;margin:0 0 8px;"><strong>The chain across three context lengths.</strong>
      True budgets 16, 20, 24 as each ruler reports them:</p>
    <table>
      <tr><th>context</th><th>true budget</th><th class="fine">step-4 reading</th><th class="coarse">doubling reading</th></tr>
      <tr><td>512</td><td class="mono">16</td><td class="mono fine">16</td><td class="mono coarse">16</td></tr>
      <tr><td>1024</td><td class="mono">20</td><td class="mono fine">20</td><td class="mono coarse">32</td></tr>
      <tr><td>2048</td><td class="mono">24</td><td class="mono fine">24</td><td class="mono coarse">32</td></tr>
    </table>
    <p style="font-size:14px;color:#4a5b78;">Under the doubling ruler the last two cells are
      indistinguishable: both live in the octave <span class="mono">(16, 32]</span>, and no doubling
      sweep can separate two budgets inside one octave. The reported "plateau at 32" is a property
      of the ruler, not of the model.</p>
  </div>
</div>

<script>
const kEl = document.getElementById('kstar'), dEl = document.getElementById('step');
const cv = document.getElementById('ruler'), ctx = cv.getContext('2d');

function readArith(d, k){ return d * Math.ceil(k / d); }
function readDyad(k){ let e = 0; while ((1 << e) < k) e++; return 1 << e; }
function weight(k){ return k.toString(2).split('').filter(c => c === '1').length; }

function draw(k, d){
  const W = cv.width, H = cv.height, L = 70, R = W - 40, N = 64;
  const x = v => L + (R - L) * (v / N);
  ctx.clearRect(0,0,W,H);
  ctx.lineWidth = 3;

  // axis
  ctx.strokeStyle = '#9fb0c9';
  ctx.beginPath(); ctx.moveTo(L, H-80); ctx.lineTo(R, H-80); ctx.stroke();

  // fine marks
  ctx.strokeStyle = '#1f77b4';
  for (let m = d; m <= N; m += d){
    ctx.beginPath(); ctx.moveTo(x(m), H-80); ctx.lineTo(x(m), H-125); ctx.stroke();
  }
  // dyadic marks
  ctx.strokeStyle = '#d62728';
  for (let e = 0; (1<<e) <= N; e++){
    const m = 1<<e;
    ctx.beginPath(); ctx.moveTo(x(m), H-80); ctx.lineTo(x(m), H-35); ctx.stroke();
  }

  // truth
  const fr = readArith(d,k), cr = readDyad(k);
  ctx.strokeStyle = '#12203a'; ctx.setLineDash([9,7]);
  ctx.beginPath(); ctx.moveTo(x(k), 40); ctx.lineTo(x(k), H-80); ctx.stroke();
  ctx.setLineDash([]);
  ctx.fillStyle = '#12203a'; ctx.font = '26px Georgia';
  ctx.fillText('k* = ' + k, x(k) + 10, 34);

  // overstatement bars
  ctx.fillStyle = 'rgba(31,119,180,.30)';
  ctx.fillRect(x(k), 60, x(fr) - x(k), 46);
  ctx.fillStyle = '#1f77b4'; ctx.font = '22px Georgia';
  ctx.fillText('fine reads ' + fr + '  (+' + (fr-k) + ')', x(fr) + 12, 96);

  ctx.fillStyle = 'rgba(214,39,40,.28)';
  ctx.fillRect(x(k), 130, x(cr) - x(k), 46);
  ctx.fillStyle = '#d62728';
  ctx.fillText('doubling reads ' + cr + '  (+' + (cr-k) + ')', x(cr) + 12, 166);

  ctx.fillStyle = '#4a5b78'; ctx.font = '20px Georgia';
  ctx.fillText('budget axis  1 … 64', L, H-14);
}

function bitsHTML(k){
  return k.toString(2).split('').map(b =>
    '<span class="' + (b === '1' ? 'one' : '') + '">' + b + '</span>').join('');
}

function update(){
  const k = +kEl.value, d = +dEl.value;
  document.getElementById('kval').textContent = k;
  document.getElementById('dval').textContent = d;
  document.getElementById('d1').textContent = d;
  const fr = readArith(d,k), cr = readDyad(k), w = weight(k);
  const marks = [];
  for (let m = d; m <= 64; m += d) marks.push(m);
  document.getElementById('fineMarks').textContent = marks.slice(0,9).join(', ') + (marks.length>9?', …':'');
  document.getElementById('fineRead').textContent = fr;
  document.getElementById('coarseRead').textContent = cr;
  document.getElementById('fineOver').textContent = '+' + (fr - k);
  document.getElementById('coarseOver').textContent = '+' + (cr - k);
  document.getElementById('fineExact').textContent = (fr === k)
      ? 'yes — ' + d + ' divides ' + k : 'no — ' + d + ' does not divide ' + k;
  document.getElementById('coarseExact').textContent = (cr === k)
      ? 'yes — binary weight 1' : 'no — binary weight ' + w;
  document.getElementById('wt').textContent = w;
  document.getElementById('bits').innerHTML = bitsHTML(k);

  const e = Math.log2(cr);
  let msg;
  if (cr === k){
    msg = '<strong>k* = ' + k + ' = 2<sup>' + e + '</sup> is a power of two.</strong> Its base-two digit sum is 1, ' +
          'so the doubling ruler is exact here — the only circumstance in which it can be.';
  } else {
    msg = '<strong>k* = ' + k + ' has binary weight ' + w + ', so a doubling sweep <em>cannot</em> report it.</strong> ' +
          'It lies in the octave (' + (cr/2) + ', ' + cr + '], and every budget in that octave is reported as ' + cr +
          ' — an overstatement of ' + (cr - k) + ' keys. Any other true knee in the same octave would be reported identically.';
  }
  if (fr === k){
    msg += ' The step-' + d + ' ruler <em>is</em> exact, because ' + d + ' divides ' + k + '.';
  } else {
    msg += ' The step-' + d + ' ruler reports ' + fr + '; it is exact only on multiples of ' + d + '.';
  }
  document.getElementById('verdict').innerHTML = msg;
  draw(k, d);
}

kEl.addEventListener('input', update);
dEl.addEventListener('input', update);
update();
</script>
</body>
</html>
"""

WIDGET_BRACKET = r"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1"/>
<title>What Five Numbers Determine — the bracket explorer</title>
<style>
  :root { --ink:#12203a; --paper:#f7f9fc; --pass:#2e8b57; --fail:#b03a3a; --gold:#e8a33d; }
  body { margin:0; padding:24px; background:var(--paper); color:var(--ink);
         font-family:"Iowan Old Style", Georgia, "Times New Roman", serif; }
  .wrap { max-width:1000px; margin:0 auto; }
  h1 { font-size:25px; margin:0 0 6px; }
  p.sub { margin:0 0 18px; color:#4a5b78; font-size:15px; }
  .panel { background:#fff; border:1px solid #dde4ee; border-radius:12px; padding:18px 20px;
           margin-bottom:18px; box-shadow:0 1px 3px rgba(20,40,80,.06); }
  canvas { width:100%; height:320px; display:block; }
  input[type=range]{ width:100%; }
  label { font-size:14px; font-weight:600; }
  table { border-collapse:collapse; width:100%; font-size:14px; }
  th,td { padding:7px 9px; border-bottom:1px solid #e6ecf5; text-align:center; }
  th { font-variant:small-caps; color:#4a5b78; letter-spacing:.5px; }
  .mono { font-family:"SF Mono", Menlo, Consolas, monospace; }
  .pass { color:var(--pass); font-weight:700; }
  .fail { color:var(--fail); font-weight:700; }
  .callout { border-radius:9px; padding:13px 15px; font-size:15px; }
  .ok { background:#eef7f0; border:1px solid #cfe6d6; }
  .warn { background:#fff8ec; border:1px solid #f0dcb8; }
  button { font:inherit; padding:7px 13px; border-radius:8px; border:1px solid #c9d5e6;
           background:#fff; cursor:pointer; margin-right:8px; }
  button.active { background:var(--gold); color:#fff; border-color:var(--gold); }
</style>
</head>
<body>
<div class="wrap">
  <h1>What Five Numbers Determine</h1>
  <p class="sub">The sweep measured retained attention mass at budgets 4, 8, 12, 20 and 24 against a gate of
  0.98. Slide the hidden crossing point: every setting below reproduces <em>all five</em> measured numbers,
  and every one of them is reported as 20.</p>

  <div class="panel">
    <label for="t">Hidden true knee <span class="mono">k*</span> = <span id="tval" class="mono">20</span>
      &nbsp;— drag anywhere in the bracket</label>
    <input id="t" type="range" min="13" max="20" value="20"/>
    <canvas id="plot" width="1900" height="620"></canvas>
  </div>

  <div class="panel">
    <table>
      <tr><th>budget k</th><th>4</th><th>8</th><th>12</th><th class="mono">16</th><th>20</th><th>24</th></tr>
      <tr><td>measured mass</td><td class="mono">0.8940</td><td class="mono">0.9520</td>
          <td class="mono">0.9662</td><td class="mono" style="background:#fff3d6">never measured</td>
          <td class="mono">0.9803</td><td class="mono">0.9851</td></tr>
      <tr><td>clears 0.98?</td><td class="fail">no</td><td class="fail">no</td><td class="fail">no</td>
          <td id="c16" class="mono">?</td><td class="pass">yes</td><td class="pass">yes</td></tr>
    </table>
  </div>

  <div class="panel">
    <p style="margin:0 0 10px;font-size:14px;"><strong>What can you conclude?</strong> Test a claim:</p>
    <button id="b1" class="active">20 keys suffice</button>
    <button id="b2">12 keys do not suffice</button>
    <button id="b3">the knee is exactly 20</button>
    <button id="b4">the chain 16 &lt; 20 &lt; 24 is strictly increasing</button>
    <div id="claim" class="callout ok" style="margin-top:14px;"></div>
  </div>

  <div class="panel warn callout">
    <strong>The hole.</strong> The swept set contains no point strictly between 12 and 20. So the data
    constrains the truth only to the half-open interval <span class="mono">(12, 20]</span> — and every
    integer in it is realised by a genuine nondecreasing profile that matches the table exactly. Since 16
    lies in that interval, and 16 is the budget reported at the neighbouring context length of 512 tokens,
    this sweep cannot tell whether the two context lengths differ at all. One extra measurement, at
    <span class="mono">k = 16</span>, would settle it.
  </div>
</div>

<script>
const TABLE = [[4,0.8940],[8,0.9520],[12,0.9662],[20,0.9803],[24,0.9851]];
const GATE = 0.98;
const tEl = document.getElementById('t');
const cv = document.getElementById('plot'), ctx = cv.getContext('2d');

function profile(t, k){
  if (k < 4)  return 0.862;
  if (k < 8)  return 0.8940;
  if (k < 12) return 0.9520;
  if (k < t)  return 0.9662;
  if (k < 24) return 0.9803;
  return 0.9851;
}

function draw(t){
  const W = cv.width, H = cv.height, L = 95, R = W - 45, T = 35, B = H - 70;
  const kmax = 28, ylo = 0.855, yhi = 1.0;
  const X = k => L + (R - L) * (k / kmax);
  const Y = v => B - (B - T) * ((v - ylo) / (yhi - ylo));
  ctx.clearRect(0,0,W,H);

  // bracket shading
  ctx.fillStyle = 'rgba(232,163,61,.16)';
  ctx.fillRect(X(12), T, X(20) - X(12), B - T);
  ctx.fillStyle = '#a9762b'; ctx.font = '22px Georgia';
  ctx.fillText('bracket (12, 20]', X(12) + 14, T + 30);

  // axes
  ctx.strokeStyle = '#9fb0c9'; ctx.lineWidth = 2;
  ctx.beginPath(); ctx.moveTo(L, T); ctx.lineTo(L, B); ctx.lineTo(R, B); ctx.stroke();
  ctx.fillStyle = '#4a5b78'; ctx.font = '20px Georgia';
  for (let k = 4; k <= kmax; k += 4){
    ctx.beginPath(); ctx.moveTo(X(k), B); ctx.lineTo(X(k), B + 8); ctx.stroke();
    ctx.fillText(k, X(k) - 8, B + 32);
  }
  ctx.fillText('budget k', (L + R)/2 - 40, B + 60);

  // gate
  ctx.strokeStyle = '#b03a3a'; ctx.lineWidth = 3; ctx.setLineDash([12,8]);
  ctx.beginPath(); ctx.moveTo(L, Y(GATE)); ctx.lineTo(R, Y(GATE)); ctx.stroke();
  ctx.setLineDash([]);
  ctx.fillStyle = '#b03a3a'; ctx.fillText('gate 0.98', L + 8, Y(GATE) - 12);

  // ghost family
  ctx.lineWidth = 2;
  for (let s = 13; s <= 20; s++){
    ctx.strokeStyle = (s === t) ? '#12203a' : 'rgba(31,119,180,.22)';
    ctx.lineWidth = (s === t) ? 5 : 2;
    ctx.beginPath();
    for (let k = 1; k <= kmax; k++){
      const xa = X(k), xb = X(k+1), y = Y(profile(s,k));
      if (k === 1) ctx.moveTo(xa, y); else ctx.lineTo(xa, y);
      ctx.lineTo(Math.min(xb, R), y);
    }
    ctx.stroke();
  }

  // 16 marker
  ctx.strokeStyle = '#12203a'; ctx.lineWidth = 2; ctx.setLineDash([4,6]);
  ctx.beginPath(); ctx.moveTo(X(16), T); ctx.lineTo(X(16), B); ctx.stroke();
  ctx.setLineDash([]);
  ctx.fillStyle = '#12203a'; ctx.fillText('k = 16 never measured', X(16) - 150, T + 66);

  // measured points
  ctx.fillStyle = '#12203a';
  TABLE.forEach(([k,v]) => {
    ctx.beginPath(); ctx.arc(X(k), Y(v), 9, 0, 6.3); ctx.fill();
    ctx.font = '19px Georgia';
    ctx.fillText(v.toFixed(4), X(k) - 42, Y(v) - 18);
  });

  // crossing marker
  ctx.fillStyle = '#2e8b57';
  ctx.beginPath(); ctx.arc(X(t), Y(0.9803), 12, 0, 6.3); ctx.fill();
  ctx.font = '24px Georgia';
  ctx.fillText('crosses at ' + t, X(t) + 18, Y(0.9803) + 44);
}

const CLAIMS = {
  b1: [true,  '<strong>Certified.</strong> The measured value at 20 is 0.9803 &ge; 0.98, and this is true for every profile matching the table. Twenty keys suffice — this is the number you ship.'],
  b2: [true,  '<strong>Certified.</strong> The measured value at 12 is 0.9662 &lt; 0.98, so the true knee is strictly greater than 12, for every matching profile.'],
  b3: [false, '<strong>Not certified.</strong> 20 is what the sweep <em>reports</em>, and that reading is forced. But the true knee could be any integer in (12, 20]: an explicit nondecreasing profile reproducing all five measurements crosses the gate at 13, another at 14, and so on up to 20.'],
  b4: [false, '<strong>Not certified.</strong> The middle cell could itself be 16, in which case the chain reads 16, 16, 24 and the first step is flat. Nothing in the five measurements excludes it, because 16 was never swept. Measuring the single point k = 16 at context 1024 decides the question.']
};

function setClaim(id){
  ['b1','b2','b3','b4'].forEach(b => document.getElementById(b).classList.toggle('active', b === id));
  const [ok, text] = CLAIMS[id];
  const box = document.getElementById('claim');
  box.className = 'callout ' + (ok ? 'ok' : 'warn');
  box.innerHTML = text;
}
['b1','b2','b3','b4'].forEach(b => document.getElementById(b).onclick = () => setClaim(b));

function update(){
  const t = +tEl.value;
  document.getElementById('tval').textContent = t;
  const c16 = document.getElementById('c16');
  if (t <= 16){ c16.textContent = 'would be yes'; c16.className = 'mono pass'; }
  else { c16.textContent = 'would be no'; c16.className = 'mono fail'; }
  draw(t);
}
tEl.addEventListener('input', update);
setClaim('b1');
update();
</script>
</body>
</html>
"""

INTERACTIVE_DEMOS: List[Dict[str, str]] = [
    {
        "title": "The Ruler Simulator: Watch a Hidden Knee Become Two Different Numbers",
        "description": (
            "An interactive bench in which you set the true crossing point k* of a hidden monotone "
            "profile and immediately see what each ruler reports. A canvas draws the budget axis "
            "with the marks of a step-d arithmetic sweep and of the doubling sweep, the true knee "
            "as a dashed line, and the two overstatements as coloured bars whose lengths are "
            "read_G(k*) - k*. Live panels show the binary expansion of k* with its one-bits "
            "highlighted, so the digit-sum criterion becomes visible: the doubling ruler is exact "
            "exactly when a single bit is lit. A running verdict explains, in words, which octave "
            "the hidden knee lives in and which other knees would be reported identically. A fixed "
            "table at the bottom shows the three-context chain 16, 20, 24 collapsing to 16, 32, 32 "
            "under the doubling ruler."
        ),
        "html": WIDGET_RULER,
    },
    {
        "title": "The Bracket Explorer: Eight Truths Behind One Reported Number",
        "description": (
            "An interactive study of exactly how much five measurements determine. The five "
            "measured retained-mass values are plotted against the gate 0.98, together with the "
            "whole family of nondecreasing staircase profiles consistent with them; a slider picks "
            "which member of the family is the 'truth', highlighting it against its ghosted "
            "siblings. Whatever you choose, the sweep reports 20 — that reading is forced — but the "
            "true crossing point moves freely across the shaded bracket (12, 20], which contains "
            "the unmeasured budget 16. A claim-tester lets the reader click four natural "
            "conclusions and see which are certified by the data ('20 keys suffice', '12 do not') "
            "and which are not ('the knee is exactly 20', 'the cross-context chain is strictly "
            "increasing'), with the reason given in each case."
        ),
        "html": WIDGET_BRACKET,
    },
]

# ---------------------------------------------------------------------------
# Interactive layout narrative
# ---------------------------------------------------------------------------

INTERACTIVE_LAYOUT = r"""# The Ruler Is Part of the Result

## A measurement that moved without anything changing

Somewhere inside a language model, attention weights are spread over the tokens already read.
Most of the weight sits on a few positions, so an engineer asks the natural question: **how many
of the top-weighted positions must I keep to preserve $98\%$ of the mass?** Write $f(k)$ for the
mass captured by the top $k$ weights — a nondecreasing function of $k$ — and define the *knee*

$$k^\ast \;=\; \min\{\, k : f(k) \ge 0.98 \,\}.$$

That single integer is the cache size you ship.

Here is the puzzle that starts this story. Sweeping budgets over the doubling ladder
$4, 8, 16, 32, \dots$ at context length $1024$ returned **32**. A later sweep — same model, same
corpus, same gate — over the evenly spaced set $\{4, 8, 12, 20, 24\}$ returned **20**. Nothing
about the system changed. Only the ruler changed.

By the end of this page you will be able to predict such disagreements *before running the
experiment*, and to say precisely which conclusions a given sweep is capable of supporting.

---

## 1. Play first: the two rulers

Set a hidden true knee and watch what each ruler reports. Notice two things as you drag: the
reported value is never *below* the truth, and the doubling ruler is exact only at the powers of
two.

{{interactive_demo:0}}

<details>
<summary><strong>Why "never below"? The formal set-up in one paragraph</strong></summary>

A **sweep grid** is an unbounded set $G \subseteq \mathbb{N}$ of budgets you are willing to
evaluate. The **reading** of an integer $k$ is the first mark at or beyond it,

$$\operatorname{read}_G(k) \;=\; \min\{\, g \in G : g \ge k \,\}.$$

Because the minimum is taken over marks that are $\ge k$, we always have $k \le \operatorname{read}_G(k)$:
the operator is *inflationary*. It is also *monotone* ($k \le k' \Rightarrow \operatorname{read}_G(k) \le \operatorname{read}_G(k')$),
*idempotent* ($\operatorname{read}_G(\operatorname{read}_G(k)) = \operatorname{read}_G(k)$), and its fixed points are exactly the grid points.
In the language of order theory it is a [closure operator](https://en.wikipedia.org/wiki/Closure_operator)
on $(\mathbb{N}, \le)$ whose closed elements are $G$.
</details>

---

## 2. The one theorem that explains everything

> **Measurement Theorem.** Let $f$ be nondecreasing and let the gate $\tau$ be met somewhere, with
> true knee $k^\ast = \min\{k : f(k) \ge \tau\}$. Then for every sweep grid $G$,
> $$\min\{\, g \in G : f(g) \ge \tau \,\} \;=\; \operatorname{read}_G(k^\ast).$$

Read it slowly, because it changes what a measurement *is*. The left side is what your harness
prints. The right side is a purely arithmetic function of a number nobody observed. They are
equal. **A grid measurement is not an estimate with an error term; it is the truth, rounded up to
the nearest mark.**

<details>
<summary><strong>Proof (three lines)</strong></summary>

We show the two sets whose minima are taken are the same set. If $g \in G$ and $f(g) \ge \tau$,
then $g$ belongs to the set defining $k^\ast$, so $k^\ast \le g$. Conversely if $g \in G$ and
$k^\ast \le g$, monotonicity of $f$ gives $f(g) \ge f(k^\ast) \ge \tau$. Hence
$\{g \in G : f(g) \ge \tau\} = \{g \in G : g \ge k^\ast\}$, and taking minima gives the claim. $\blacksquare$

Two corollaries fall out immediately: the reading is *exact* iff $k^\ast \in G$; and if $H \subseteq G$
(so $H$ is the coarser sweep) then the finer sweep never reports the larger value.
</details>

<details>
<summary><strong>Could a cleverer read-out do better? No — a uniqueness theorem</strong></summary>

> **Uniqueness of the Read-Out.** If $M : \mathbb{N} \to \mathbb{N}$ is inflationary, monotone,
> idempotent, and satisfies $M(k) = k$ exactly on $G$, then $M = \operatorname{read}_G$.

*Proof.* Fix $k$. By idempotence $M(k)$ is a fixed point, hence lies in $G$; with $k \le M(k)$ and
minimality of the reading, $\operatorname{read}_G(k) \le M(k)$. Conversely $\operatorname{read}_G(k) \in G$ is fixed by $M$, and
monotonicity on $k \le \operatorname{read}_G(k)$ gives $M(k) \le M(\operatorname{read}_G(k)) = \operatorname{read}_G(k)$. $\blacksquare$

So there is no post-processing trick. Any alternative read-out must under-report sometimes, or be
non-monotone, or be unstable under re-measurement, or be wrong at a point you actually measured.
Each is a real modelling commitment.
</details>

---

## 3. When is a ruler right? Divisibility and binary digits

Two grid families matter in practice.

- The **arithmetic grid** $A_d$ of step $d$: its reading is $d\lceil k/d\rceil$, exact iff $d \mid k$.
  For $d = 4$ this says $k$ must end in at least two binary zeros, i.e. its
  [$2$-adic valuation](https://en.wikipedia.org/wiki/P-adic_valuation) is at least $2$.
- The **doubling grid** $D = \{1,2,4,8,\dots\}$: its reading is $2^{\lceil\log_2 k\rceil}$.

> **Digit-Sum Criterion.** For $k > 0$, a doubling sweep reports $k$ exactly if and only if the
> base-two digit sum of $k$ is $1$ — that is, iff $k$ is a power of two.

This is the punchline of the widget above: whether your experiment can possibly be right about a
budget is decided by the *binary weight* of a number you have not seen. And $16 = 10000_2$ has
weight $1$, while $20 = 10100_2$ and $24 = 11000_2$ have weight $2$.

> **Explicit overstatement.** If $2^e < k \le 2^{e+1}$ then $\operatorname{read}_D(k) = 2^{e+1}$, overstating by
> $2^{e+1} - k$. Hence $16 \mapsto 16$, $20 \mapsto 32$ ($+12$ keys), $24 \mapsto 32$ ($+8$ keys).

> **Octave Collapse.** If $2^e < k \le k' \le 2^{e+1}$ then $\operatorname{read}_D(k) = \operatorname{read}_D(k')$: no doubling
> sweep can separate two knees inside a single octave.

The chain $16 < 20 < 24$ therefore has doubling image $16, 32, 32$. The old "context $1024$ gives
$32$" and the "second corpus at $2048$ gives $32$" are the *same rounding event* — not two facts
about the world. Comfortingly, the damage runs one way only: if the *readings* strictly increase,
the truths strictly increase. Coarsening destroys resolution; it never invents it.

Here is that geometry, drawn:

{{visualization:0}}

---

## 4. What five numbers actually determine

Now the honest reckoning. The fine sweep produced

| $k$ | $4$ | $8$ | $12$ | $20$ | $24$ |
|---|---|---|---|---|---|
| retained | $0.8940$ | $0.9520$ | $0.9662$ | $0.9803$ | $0.9851$ |

against the gate $0.98$. Two of the five numbers do all the work: $f(12) = 0.9662 < 0.98$ and
$f(20) = 0.9803 \ge 0.98$.

> **Forced Reading.** Every nondecreasing profile reproducing these five values makes the least
> swept budget clearing the gate equal to $20$.

> **Bracket Theorem.** The same hypotheses force $12 < k^\ast \le 20$ — and nothing more.

> **Tightness.** For every integer $t$ with $12 < t \le 20$, there is a nondecreasing profile
> reproducing all five measured values whose true knee is exactly $t$.

Explore that family yourself. Each position of the slider is a *different truth* that produces
*identical data*:

{{interactive_demo:1}}

<details>
<summary><strong>The witnesses, written out</strong></summary>

For $12 < t \le 20$ define the staircase
$$P_t(k) = \begin{cases} 0 & k < 4\\ 0.8940 & 4 \le k < 8\\ 0.9520 & 8 \le k < 12\\ 0.9662 & 12 \le k < t\\ 0.9803 & t \le k < 24\\ 0.9851 & 24 \le k.\end{cases}$$
It is nondecreasing (the values increase and the branch conditions are nested intervals). It matches
the table: $4$ hits the second branch, $8$ the third, $12$ the fourth because $12 < t$, $20$ the
fifth because $t \le 20 < 24$, and $24$ the last. Its knee is $t$: $P_t(t) = 0.9803 \ge 0.98$, while
every $k < t$ has $P_t(k) \le 0.9662 < 0.98$. Taking $t = 16$ and $t = 20$ gives two profiles with
identical data and different truths. $\blacksquare$
</details>

**The hole.** The swept set contains no point strictly between $12$ and $20$; in particular it omits
$16$, which is the budget reported at the neighbouring context length $512$. So:

- **Certified:** twenty keys clear the gate at context $1024$; twelve do not. Ship $20$.
- **Certified:** the earlier reading $32$ is a coarser rounding of this same truth.
- **Not certified:** that the chain $16 < 20 < 24$ across contexts $\{512, 1024, 2048\}$ is
  *strictly* increasing. The middle cell might be $16$ too.

One measurement — $k = 16$ at context $1024$ — decides it. Identifying that measurement is the
practical payoff of taking the arithmetic seriously.

Here is the whole logical situation in one figure:

{{visualization:2}}

---

## 5. How much can a ruler see at all?

Step back from one experiment and ask a design question. Over a window $[1, N]$ of possible knees:

- a step-$d$ sweep resolves exactly $\lfloor N/d\rfloor$ budgets — a positive proportion $1/d$;
- a doubling sweep resolves at most $\log_2 N + 1$ — a vanishing proportion;
- from $N = 32$ upward the step-$4$ sweep strictly wins, and the gap grows exponentially.

Sharper, and more disquieting:

> **Verdict Bound.** Across all true knees in $(0, N]$, a doubling sweep can emit at most
> $\lceil\log_2 N\rceil + 1$ distinct values. A chain of $r$ knees therefore contains at least
> $r - \lceil\log_2 N\rceil - 1$ repeated reports.

Apparent flatness in a long coarse chain can be **forced by counting**, before any modelling
assumption whatsoever.

{{visualization:1}}

<details>
<summary><strong>Resolution power is the divisor function — and it is not monotone</strong></summary>

Which arithmetic sweeps resolve a given budget $k$? Exactly those whose step divides $k$. So the
number of arithmetic sweeps that can see $k$ is the
[divisor-counting function](https://en.wikipedia.org/wiki/Divisor_function) $\tau(k)$. Along our
chain, $\tau(16) = 5$, $\tau(20) = 6$, $\tau(24) = 8$ — apparently increasing. But $\tau$ is
famously erratic, and the very next fine-grid cell breaks it: $\tau(28) = 6 < 8 = \tau(24)$. Bigger
budgets are not systematically easier to resolve.
</details>

> **The GCD Principle.** A step-$d$ sweep resolves every member of a finite chain $K$ if and only
> if $d \mid \gcd K$. Hence the *coarsest* arithmetic sweep that sees a whole chain has step exactly
> $\gcd K$.

Since $\gcd\{16, 20, 24\} = 4$, the step-$4$ grid is the unique coarsest arithmetic ruler that can
resolve all three cells — the choice was forced, not lucky. (One line: $d \mid 16$ and $d \mid 20$
imply $d \mid 4$.)

---

## 6. The toolkit

Four routines encode everything above. The first is the reading operator itself, together with the
two exactness criteria:

{{algorithm:0}}

The second exploits monotonicity to reduce a sweep from $r$ oracle calls to $\lceil\log_2 r\rceil$ —
worth having when a single call is an expensive model evaluation:

{{algorithm:1}}

The third is the one that would have prevented the over-claim: it returns the *bracket*, which the
tightness theorem shows is not merely sound but complete — the strongest inference the data licenses:

{{algorithm:2}}

The fourth turns design into arithmetic: hand it the chain you hope to certify, and it returns the
cheapest sweep that can certify it:

{{algorithm:3}}

---

## 7. Run the whole story numerically

Everything above, checked on concrete numbers: the Measurement Theorem verified against three
different grids; the closure axioms tested; the exactness table with binary weights and $2$-adic
valuations; the eight witness profiles that produce identical data from different truths; the
octave collapse; the resolution and verdict counts; and the staircase bridge showing that
$20 \mapsto 32$ and $112 \mapsto 128$ are one theorem.

{{demo:0}}

<details>
<summary><strong>The staircase bridge, stated properly</strong></summary>

Let $s(b,j) = 2^b(2^j - 1)$ — in binary, $j$ ones followed by $b$ zeros. The complement identity
$s(b,j) + 2^b = 2^{b+j}$ gives, for $j \ge 2$,
$$2^{b+j-1} = 2^{b+j} - 2^{b+j-1} < 2^{b+j} - 2^b = s(b,j) \le 2^{b+j},$$
so $s(b,j)$ sits strictly inside the top octave below $2^{b+j}$ and the doubling sweep reports
$2^{b+j}$.

> **Staircase Reading.** Every binary staircase number with at least two ones is read by a doubling
> sweep as its ceiling power of two.

An earlier round in this programme reported a fine-grid knee of $112 = 2^4(2^3 - 1) = s(4,3)$ where
a doubling sweep had said $128 = 2^7$. That is this theorem, and so is $20 \mapsto 32$. "Knees
quantize to the grid" is one statement with instances, not a pile of coincidences.
</details>

---

## 8. What to carry away

The moral is not "always use a finer grid" — finer grids cost evaluations, and the counting
results price the trade-off exactly. The moral is that **the ruler is part of the result**, and its
contribution is computable in advance:

1. **Report brackets, not points.** A sweep yields $(g_{i-1}, g_i]$; the point value is a rounding.
2. **Check the grid's holes against your claim.** Before asserting a strict chain, verify each
   bracket excludes its neighbour's value. Here $16 \in (12, 20]$ — and that single containment
   dissolves the strictness claim while leaving the deployment claim untouched.
3. **A coarse–fine disagreement is not evidence.** The finer sweep always reports the smaller value;
   that is a theorem about the operator, not a discovery about the system.
4. **Design by $\gcd$.** The step should divide the gcd of the chain you hope to certify.

And the theory is not about attention at all. Any *first-crossing* measurement sampled on a
restricted set behaves this way: minimum rank for a target reconstruction error, minimum bit-width
for a target accuracy loss, scaling-law breakpoints swept on doubling ladders, empirical phase
transitions on geometric size ladders, and the classical
[serial-dilution](https://en.wikipedia.org/wiki/Serial_dilution) titre, where reported values are
literally grid readings. In every one of them, a reported breakpoint that happens to be a power of
two carries strictly less information than one that is not — because only the latter could not have
come from a doubling sweep.

Elementary divisibility, binary weight, and greatest common divisors, deciding how much memory a
language model needs. When two sweeps disagree, the first question is never "which experiment was
wrong?" It is: *are these two numbers the same truth, seen through two different rulers?*
"""

# ---------------------------------------------------------------------------
# Future directions (from Phase A, lightly edited)
# ---------------------------------------------------------------------------

FUTURE_DIRECTIONS = r"""# Future directions — after the grid-quantization round

Three strands of theory were developed in this round:

* **Grid quantization.** Grids, the reading operator (a closure operator on the natural numbers),
  the **measurement theorem** (*a grid reading is the grid-rounding of the true knee*), the
  **uniqueness theorem** (rounding is the only inflationary, monotone, idempotent read-out with the
  grid as fixed-point set), the dyadic reading $2^{\lceil\log_2 k\rceil}$, exactness as a base-two
  digit-sum / $2$-adic valuation condition, and the instantiation on the retained-attention profile.
* **The five-point table.** The reading $20$ is forced for every monotone profile; the true knee is
  bracketed in $(12, 20]$ and the bracket is **tight** (every value in it is realised), because the
  reported grid omits $16$; the coarse chain collapse $\{16, 32, 32\}$; and the bridge showing that
  the earlier misreading $112 \mapsto 128$ is the same mechanism as $20 \mapsto 32$.
* **Resolution counting.** $\lfloor N/d\rfloor$ resolvable budgets for a step-$d$ sweep versus at
  most $\log_2 N + 1$ for a doubling sweep; the $\lceil\log_2 N\rceil + 1$ verdict bound; resolution
  power as the divisor function $\tau$; and the **gcd design principle** with its instance
  $4 = \gcd\{16, 20, 24\}$.

Two conjectures formulated during the round (the gcd principle and the uniqueness of rounding) were
closed inside the round and are now theorems; what follows are the conjectures that remain open.

## 1. Budgeted grid optimality: additive versus multiplicative error

**Conjecture.** Fix a window $[1, N]$ and a budget of $r$ sweep points. The sweep set minimising the
worst-case *additive* overstatement $\max_k (\operatorname{read}(k) - k)$ is the arithmetic grid of step
$\lceil N/r\rceil$, while the sweep set minimising the worst-case *multiplicative* overstatement
$\max_k \operatorname{read}(k)/k$ is the geometric grid of ratio $N^{1/r}$ (rounded to integers). In particular
the doubling grid is optimal for the wrong loss function, which is exactly why it misreports knees
by up to a factor $2$ while costing only $\log_2 N$ points.

The key insight is that the two grid families in this round are not "coarse versus fine" but
*optima of two different loss functions*, so the discrepancy between the two reported knees is a
statement about which error the harness should minimise. Why now? The counting results for both
grid families, and the explicit overstatement of the doubling sweep, are already in place; the
optimisation needs only an exchange argument on gap lengths.

## 2. Octave-collapse bound on certifiable chain length

**Conjecture.** If a knee chain $k_1 < \cdots < k_r$ lies in $[1, N]$, a doubling sweep reports at
most $\lceil\log_2 N\rceil + 1$ distinct values, so for $r > \lceil\log_2 N\rceil + 1$ at least
$r - \lceil\log_2 N\rceil - 1$ reported "plateaus" are artifacts; moreover the number of *genuine*
strict increases such a sweep can certify equals the number of octaves the chain meets, minus one.

The key insight is that the information content of a coarse sweep is bounded by its output alphabet,
so claims about chain shape are limited by counting rather than by measurement quality.

## 3. Immediate experimental follow-ups

* Run the missing cell at $k = 16$, context $1024$: it is the single measurement that decides
  whether the cross-context chain is strictly increasing or has a plateau.
* Fine grids at the neighbouring context lengths, so that all three cells carry brackets of the
  same width.
* Domain-jump corpora, to test whether apparent corpus sensitivity survives once both readings are
  taken on the same grid.
* A fine-grid sweep on a larger model, where the reported chain is flat-to-declining against a
  rising baseline, and where the bracket analysis should be applied before any invariance claim.

## 4. Two further open problems

* **Adaptive sweeps.** Binary search locates the knee exactly in $\lceil\log_2 N\rceil$ evaluations,
  beating every fixed grid of comparable size. Formalise the trade-off between comparability of a
  fixed sweep across conditions and resolution within a condition, and find the optimal partially
  adaptive scheme.
* **Noisy readings.** With the profile observed with error, characterise the bias and variance of
  the grid reading, and determine the grid minimising mean-squared error of the reported knee at a
  fixed evaluation budget. The closure-operator structure suggests the estimator inherits an
  inflationary bias even before noise is considered.
"""

# ---------------------------------------------------------------------------
# Assemble
# ---------------------------------------------------------------------------


def main() -> None:
    demo_src = load("demo.py")
    lean_files = [
        "Catalog/NumberTheory/GridKneeQuantization.lean",
        "Catalog/NumberTheory/GridKneeNet62.lean",
        "Catalog/NumberTheory/GridKneeResolution.lean",
    ]
    lean_proofs = "\n\n".join(
        f"-- ===== FILE: {p} =====\n" + load(p) for p in lean_files
    )

    package: Dict[str, Any] = {
        "title": "The Ruler Is Part of the Result: Grid Quantization of Threshold Measurements",
        "domain": "Applications",
        "description": (
            "A measurement of a monotone threshold taken on a restricted sweep grid is proved to be "
            "exactly the grid-rounding of the true crossing point, making coarse/fine discrepancies "
            "an arithmetic phenomenon governed by divisibility, base-two digit sums and greatest "
            "common divisors. Applied to a five-point attention-budget table, the theory certifies "
            "the deployment reading of 20 keys while proving that the same data cannot separate a "
            "true knee of 16 from one of 20."
        ),
        "authors": ["Aristotle"],
        "date": "2026-09-02",
        "key_results": [
            "Measurement Theorem: sweeping a nondecreasing profile against a gate on a sweep grid "
            "returns exactly the grid-rounding of the true knee, so a grid measurement carries no "
            "independent error term.",
            "Uniqueness of the read-out: rounding up is the only inflationary, monotone, idempotent "
            "map on the natural numbers whose fixed points are the grid points.",
            "Digit-sum exactness criterion: a doubling sweep reports a budget exactly iff its "
            "base-two digit sum is one, and otherwise overstates it by the distance to the next "
            "power of two; a step-d sweep is exact iff d divides the budget.",
            "Forced reading with a tight bracket: every nondecreasing profile matching the five "
            "measured retained-mass values reports 20, while the true knee is pinned only to the "
            "interval (12, 20] — and every value in that interval is realised, so 16 and 20 are "
            "indistinguishable from the data.",
            "GCD design principle and resolution counting: a step-d sweep resolves a finite chain "
            "of knees iff d divides their greatest common divisor (making step 4 the coarsest sweep "
            "resolving 16, 20, 24), a step-d sweep resolves floor(N/d) budgets in a window while a "
            "doubling sweep emits at most ceil(log2 N) + 1 distinct verdicts in total.",
            "Staircase bridge: every binary staircase number 2^b(2^j - 1) with at least two ones is "
            "read by a doubling sweep as 2^(b+j), so the misreadings 20 to 32 and 112 to 128 are "
            "instances of a single theorem.",
        ],
        "keywords": [
            "grid rounding",
            "closure operator",
            "monotone threshold",
            "base-two digit sum",
            "divisor function",
            "greatest common divisor",
            "attention budget",
            "experiment design",
        ],
        "article": load("ARTICLE.md"),
        "research_paper": load("RESEARCH_PAPER.md"),
        "research_paper_tex": load("RESEARCH_PAPER.tex"),
        "demo": demo_src,
        "demos": [
            {
                "name": "End-to-End Numerical Verification of Grid Quantization, Bracketing and Sweep Design",
                "description": (
                    "A seven-part self-contained numerical study. Part 1 verifies the Measurement "
                    "Theorem by comparing, for an explicit profile with known true knee, the value a "
                    "sweep reports against the grid-rounding of the truth on three different grids. "
                    "Part 2 tests the four closure axioms on a candidate read-out and on a deliberately "
                    "broken one, illustrating the uniqueness theorem. Part 3 tabulates binary "
                    "expansions, digit sums, 2-adic valuations and the dyadic overstatement for the "
                    "budgets of interest. Part 4 reconstructs the eight staircase profiles consistent "
                    "with the five-point table, checks that each reproduces all measured values, and "
                    "shows that all eight report 20 while their true knees run from 13 to 20 — the "
                    "tight bracket and the hole at 16. Part 5 exhibits the octave collapse of the chain "
                    "16, 20, 24 to 16, 32, 32. Part 6 counts resolvable budgets and distinct verdicts "
                    "for both grid families, computes divisor-function resolution powers (including the "
                    "non-monotonicity tau(28) = 6 < 8 = tau(24)), and confirms the gcd design principle "
                    "step by step. Part 7 verifies the staircase reading theorem, including 112 mapping "
                    "to 128. Standard library only."
                ),
                "code": demo_src,
            }
        ],
        "algorithms": ALGORITHMS,
        "visualizations": VISUALIZATIONS,
        "interactive_demos": INTERACTIVE_DEMOS,
        "interactive_layout": INTERACTIVE_LAYOUT,
        "lean_proofs": lean_proofs,
        "future_directions": FUTURE_DIRECTIONS,
        "modules": {"demo": demo_src},
        "lean_files": lean_files,
    }

    out = ROOT / "PACKAGE.json"
    out.write_text(json.dumps(package, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"wrote {out} ({out.stat().st_size} bytes)")


if __name__ == "__main__":
    main()


"""
Grid Quantization of Threshold Measurements — numerical demonstrations.

Self-contained (standard library only). Every function is inlined and type-hinted.

The demonstrations verify, on concrete numbers, the results of the accompanying
paper:

  1. Measurement Theorem: sweeping a monotone profile on a grid returns exactly
     the grid-rounding of the true knee.
  2. Uniqueness of the read-out: rounding up is the only inflationary, monotone,
     idempotent map whose fixed points are the grid.
  3. Exactness criteria: divisibility (arithmetic grid) and base-two digit sum
     (doubling grid); explicit overstatement 2^(e+1) - k.
  4. The five-point table at context 1024: forced reading 20, tight bracket
     (12, 20], underdetermination at 16.
  5. Octave collapse of the chain 16 < 20 < 24 under a doubling sweep.
  6. Resolution counting, the verdict bound, divisor-function resolution power,
     and the gcd design principle.
  7. Binary staircase numbers: 20 -> 32 and 112 -> 128 are one mechanism.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from math import gcd
from typing import Callable, Dict, Iterable, List, Sequence, Set, Tuple

# ---------------------------------------------------------------------------
# 1. Grids and the reading operator
# ---------------------------------------------------------------------------


def read_arith(d: int, k: int) -> int:
    """Least multiple of d that is >= k (the step-d grid reading of k)."""
    if d <= 0:
        raise ValueError("step must be positive")
    if k <= 0:
        return 0
    return d * ((k + d - 1) // d)


def read_dyad(k: int) -> int:
    """Least power of two that is >= k (the doubling-grid reading of k)."""
    if k <= 1:
        return 1
    e = 0
    while (1 << e) < k:
        e += 1
    return 1 << e


def read_finite(grid: Sequence[int], k: int) -> int:
    """Least point of an explicit finite sweep set that is >= k."""
    for g in sorted(grid):
        if g >= k:
            return g
    raise ValueError(f"sweep set {sorted(grid)} does not reach {k}")


def binary_digit_sum(k: int) -> int:
    """Number of ones in the base-two expansion of k."""
    return bin(k).count("1")


def two_adic_valuation(k: int) -> int:
    """Largest e with 2^e | k (defined for k != 0)."""
    if k == 0:
        raise ValueError("valuation of 0 is undefined")
    v = 0
    while k % 2 == 0:
        k //= 2
        v += 1
    return v


def divisors(k: int) -> List[int]:
    """Sorted list of positive divisors of k > 0."""
    out: List[int] = []
    i = 1
    while i * i <= k:
        if k % i == 0:
            out.append(i)
            if i != k // i:
                out.append(k // i)
        i += 1
    return sorted(out)


def tau(k: int) -> int:
    """Divisor-counting function: the number of arithmetic sweeps resolving k."""
    return len(divisors(k))


# ---------------------------------------------------------------------------
# 2. Knees, sweeps and the Measurement Theorem
# ---------------------------------------------------------------------------


def true_knee(profile: Callable[[int], Fraction], gate: Fraction, hi: int) -> int:
    """Least k in [0, hi] with profile(k) >= gate (profile assumed nondecreasing)."""
    for k in range(hi + 1):
        if profile(k) >= gate:
            return k
    raise ValueError("gate not reached within the search window")


def measured_knee(
    profile: Callable[[int], Fraction], gate: Fraction, sweep: Sequence[int]
) -> int:
    """Least swept budget clearing the gate: what the harness reports."""
    for g in sorted(sweep):
        if profile(g) >= gate:
            return g
    raise ValueError("gate not cleared at any swept budget")


# ---------------------------------------------------------------------------
# 3. The five-point table at context 1024
# ---------------------------------------------------------------------------

GATE: Fraction = Fraction(98, 100)
TABLE: Dict[int, Fraction] = {
    4: Fraction(8940, 10000),
    8: Fraction(9520, 10000),
    12: Fraction(9662, 10000),
    20: Fraction(9803, 10000),
    24: Fraction(9851, 10000),
}
SWEEP: List[int] = sorted(TABLE)


def step_witness(t: int) -> Callable[[int], Fraction]:
    """The staircase profile matching the whole table and crossing the gate at t."""

    def profile(k: int) -> Fraction:
        if k < 4:
            return Fraction(0)
        if k < 8:
            return Fraction(8940, 10000)
        if k < 12:
            return Fraction(9520, 10000)
        if k < t:
            return Fraction(9662, 10000)
        if k < 24:
            return Fraction(9803, 10000)
        return Fraction(9851, 10000)

    return profile


def matches_table(profile: Callable[[int], Fraction]) -> bool:
    """Does the profile reproduce all five measured values and stay nondecreasing?"""
    if any(profile(k) != v for k, v in TABLE.items()):
        return False
    values = [profile(k) for k in range(0, 40)]
    return all(a <= b for a, b in zip(values, values[1:]))


# ---------------------------------------------------------------------------
# 4. Resolution counting
# ---------------------------------------------------------------------------


def resolved_arith(d: int, n: int) -> List[int]:
    """Budgets in (0, n] resolved exactly by a step-d sweep."""
    return [k for k in range(1, n + 1) if read_arith(d, k) == k]


def resolved_dyad(n: int) -> List[int]:
    """Budgets in (0, n] resolved exactly by a doubling sweep."""
    return [k for k in range(1, n + 1) if read_dyad(k) == k]


def dyad_verdicts(n: int) -> Set[int]:
    """The full set of values a doubling sweep can ever report for knees in (0, n]."""
    return {read_dyad(k) for k in range(1, n + 1)}


def coarsest_resolving_step(chain: Iterable[int]) -> int:
    """gcd of a chain: the coarsest arithmetic step resolving every member."""
    g = 0
    for k in chain:
        g = gcd(g, k)
    return g


def stair(b: int, j: int) -> int:
    """Binary staircase number: j ones followed by b zeros."""
    return (2**b) * (2**j - 1)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def banner(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_measurement_theorem() -> None:
    banner("1. Measurement Theorem: a sweep reports the grid-rounding of the truth")
    profile = step_witness(17)  # true knee 17, matches the table
    k_star = true_knee(profile, GATE, 40)
    print(f"true knee k* = {k_star}")
    for name, grid in (
        ("step-4 grid", [4 * i for i in range(1, 20)]),
        ("doubling grid", [2**e for e in range(0, 8)]),
        ("reported sweep {4,8,12,20,24}", SWEEP),
    ):
        swept = measured_knee(profile, GATE, grid)
        rounded = read_finite(grid, k_star)
        flag = "OK" if swept == rounded else "MISMATCH"
        print(f"  {name:32s} sweep says {swept:4d}   rounding says {rounded:4d}   [{flag}]")


def demo_uniqueness() -> None:
    banner("2. Uniqueness: rounding up is the only admissible read-out")
    d = 4
    limit = 40

    def is_closure(m: Callable[[int], int]) -> Tuple[bool, bool, bool, bool]:
        inflationary = all(k <= m(k) for k in range(1, limit))
        monotone = all(m(k) <= m(k + 1) for k in range(1, limit - 1))
        idempotent = all(m(m(k)) == m(k) for k in range(1, limit))
        fixed_iff_grid = all((m(k) == k) == (k % d == 0) for k in range(1, limit))
        return inflationary, monotone, idempotent, fixed_iff_grid

    good = lambda k: read_arith(d, k)                 # noqa: E731
    naughty = lambda k: read_arith(d, k) + 4 * (k % 2)  # noqa: E731  breaks monotonicity
    for name, m in (("round-up", good), ("round-up + parity nudge", naughty)):
        infl, mono, idem, fix = is_closure(m)
        agrees = all(m(k) == read_arith(d, k) for k in range(1, limit))
        print(
            f"  {name:26s} inflationary={infl!s:5s} monotone={mono!s:5s} "
            f"idempotent={idem!s:5s} fixedpts=grid={fix!s:5s}  equals rounding={agrees}"
        )
    print("  Any map with all four properties must coincide with rounding up.")


def demo_exactness() -> None:
    banner("3. Exactness criteria and the size of the coarse artifact")
    print("   k   binary     wt  v2  read_4(k)  read_dyad(k)  dyadic overstatement")
    for k in (12, 16, 20, 24, 28, 32, 112):
        print(
            f"  {k:4d}  {bin(k)[2:]:>9s}  {binary_digit_sum(k):2d}  "
            f"{two_adic_valuation(k):2d}  {read_arith(4, k):9d}  {read_dyad(k):12d}"
            f"  {read_dyad(k) - k:20d}"
        )
    print("  A doubling sweep is exact exactly at binary weight 1 (powers of two).")
    print("  A step-4 sweep is exact exactly when v2(k) >= 2.")


def demo_table_analysis() -> None:
    banner("4. The five-point table: forced reading, tight bracket, hole at 16")
    print("   k        :  " + "  ".join(f"{k:6d}" for k in SWEEP))
    print("   retained :  " + "  ".join(f"{float(TABLE[k]):.4f}" for k in SWEEP))
    print(f"   gate     :  {float(GATE):.4f}\n")

    readings = set()
    knees = []
    for t in range(13, 21):
        p = step_witness(t)
        assert matches_table(p), f"witness at t={t} fails to match the table"
        k_star = true_knee(p, GATE, 40)
        m = measured_knee(p, GATE, SWEEP)
        readings.add(m)
        knees.append(k_star)
        print(
            f"  witness crossing at t={t:2d}:  matches table = True,  "
            f"true knee = {k_star:2d},  sweep reports = {m:2d},  "
            f"step-4 rounding of k* = {read_arith(4, k_star):2d}"
        )
    print(f"\n  distinct sweep readings over all witnesses : {sorted(readings)}")
    print(f"  distinct true knees consistent with table  : {knees}")
    print("  => reading 20 is FORCED; the true knee is pinned only to (12, 20].")
    print("  => 16 and 20 are both consistent: the sweep set has no point in (12, 20).")
    print("  Certified: 20 keys clear the gate, 12 keys do not.")
    print("  Not certified: that the 1024 cell is strictly above the 512 cell (16).")


def demo_chain_collapse() -> None:
    banner("5. Octave collapse of the chain 16 < 20 < 24")
    chain = [16, 20, 24]
    print(f"  chain              : {chain}")
    print(f"  step-4 readings    : {[read_arith(4, k) for k in chain]}  (exact)")
    print(f"  doubling readings  : {[read_dyad(k) for k in chain]}  (collapsed)")
    print(f"  overstatements     : {[read_dyad(k) - k for k in chain]}")
    print("  20 and 24 both lie in the octave (16, 32]; no doubling sweep separates them.")
    print("  The old 'ctx=1024 -> 32' and the 'corpus-B 2048 -> 32' are one rounding.")


def demo_resolution_and_design() -> None:
    banner("6. Resolution counting, verdict bound and the gcd design principle")
    print("     N   |R_4(N)| = floor(N/4)   |R_dyad(N)|   distinct dyadic verdicts")
    for n in (32, 64, 128, 256, 1024):
        print(
            f"  {n:5d}   {len(resolved_arith(4, n)):18d}   "
            f"{len(resolved_dyad(n)):11d}   {len(dyad_verdicts(n)):24d}"
        )
    print("\n  resolution power tau(k) = number of arithmetic sweeps resolving k:")
    for k in (16, 20, 24, 28):
        print(f"    tau({k:3d}) = {tau(k)}   divisors = {divisors(k)}")
    print("    tau is NOT monotone in k:  tau(28) = 6 < 8 = tau(24).")

    chain = [16, 20, 24]
    g = coarsest_resolving_step(chain)
    print(f"\n  gcd{chain} = {g}: the coarsest arithmetic step resolving the whole chain.")
    for d in range(1, 13):
        resolves = all(read_arith(d, k) == k for k in chain)
        divides = (g % d == 0)
        status = "OK" if resolves == divides else "MISMATCH"
        print(
            f"    step {d:2d}: resolves chain = {str(resolves):5s}   "
            f"d | 4 = {str(divides):5s}   [{status}]"
        )


def demo_staircase_bridge() -> None:
    banner("7. Binary staircase knees: 20 -> 32 and 112 -> 128 are one mechanism")
    print("   b   j   s(b,j)   binary        read_dyad   2^(b+j)")
    for b, j in ((2, 2), (4, 3), (0, 4), (3, 2), (5, 3)):
        s = stair(b, j)
        print(
            f"  {b:2d}  {j:2d}   {s:6d}   {bin(s)[2:]:>10s}   {read_dyad(s):9d}   {2**(b+j):7d}"
        )
    assert stair(4, 3) == 112 and read_dyad(112) == 128
    print("  Every staircase with at least two ones is read as its ceiling power of two.")
    print(f"  112 = s(4,3) -> {read_dyad(112)};   20 -> {read_dyad(20)}: same theorem.")


def main() -> None:
    demo_measurement_theorem()
    demo_uniqueness()
    demo_exactness()
    demo_table_analysis()
    demo_chain_collapse()
    demo_resolution_and_design()
    demo_staircase_bridge()
    print("\nAll demonstrations completed.\n")


if __name__ == "__main__":
    main()
