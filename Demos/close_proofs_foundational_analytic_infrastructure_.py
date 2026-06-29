"""Generate PACKAGE.json from the package deliverables. Not part of the deliverable
content itself; a build helper."""
from __future__ import annotations
import json
from pathlib import Path

HERE = Path(__file__).parent

article = (HERE / "ARTICLE.md").read_text()
paper = (HERE / "RESEARCH_PAPER.md").read_text()
demo = (HERE / "demo.py").read_text()

lean_proofs = r'''-- NEW_FILE: Catalog/Speculative/AutoResearch/FibonacciEntryPoints.lean
import Mathlib

/-! # Fibonacci entry points and primitive prime divisors

The *entry point* (or *rank of apparition*) of a prime `p` is the least positive
index `k` with `p ∣ F_k`.  This file develops the basic divisibility theory of
entry points entirely from `Nat.fib_gcd` and `Nat.fib_dvd`, and uses it to give a
clean characterization of *primitive prime divisors* of Fibonacci numbers (a prime
dividing `F_n` but none of `F_1, …, F_{n-1}`).

Main results:
* `fib_dvd_gcd`            — `p ∣ F_m → p ∣ F_n → p ∣ F_{gcd m n}`.
* `dvd_fib_iff_entry_dvd`  — `p ∣ F_n ↔ entryPoint p ∣ n` (for `p` ever dividing a Fibonacci).
* `primitive_iff_entry_eq` — `p` is a primitive prime divisor of `F_n` iff `entryPoint p = n`.
* `fib_twelve_no_primitive`— the classical exception: `F_12 = 144` has *no* primitive prime divisor.
-/

namespace FibonacciEntryPoints

open Classical in
/-- The Fibonacci entry point (rank of apparition) of `p`: the least `k > 0` with
`p ∣ F_k`, or `0` if no such `k` exists. -/
noncomputable def entryPoint (p : ℕ) : ℕ :=
  if h : ∃ k, 0 < k ∧ p ∣ Nat.fib k then Nat.find h else 0

theorem fib_dvd_gcd (p m n : ℕ) (hm : p ∣ Nat.fib m) (hn : p ∣ Nat.fib n) :
    p ∣ Nat.fib (Nat.gcd m n) := by
  convert Nat.dvd_gcd hm hn using 1;
  grind +suggestions

theorem entryPoint_pos (p : ℕ) (hex : ∃ k, 0 < k ∧ p ∣ Nat.fib k) :
    0 < entryPoint p := by
  unfold entryPoint; aesop;

theorem dvd_fib_entryPoint (p : ℕ) (hex : ∃ k, 0 < k ∧ p ∣ Nat.fib k) :
    p ∣ Nat.fib (entryPoint p) := by
  convert Nat.find_spec hex |>.2 using 1;
  unfold entryPoint; aesop;

theorem entryPoint_min (p m : ℕ) (hm : 0 < m) (hlt : m < entryPoint p) :
    ¬ p ∣ Nat.fib m := by
  contrapose! hlt; unfold entryPoint at *; aesop;

theorem dvd_fib_iff_entry_dvd (p n : ℕ) (hex : ∃ k, 0 < k ∧ p ∣ Nat.fib k) :
    p ∣ Nat.fib n ↔ entryPoint p ∣ n := by
  constructor;
  · set e := entryPoint p
    have he_pos : 0 < e := entryPoint_pos p hex
    have he_div : p ∣ Nat.fib e := dvd_fib_entryPoint p hex;
    intro hn;
    contrapose! hn;
    have h_gcd_lt_e : Nat.gcd e n < e := by
      exact lt_of_le_of_ne ( Nat.le_of_dvd he_pos ( Nat.gcd_dvd_left _ _ ) ) fun h => hn <| h.symm ▸ Nat.gcd_dvd_right _ _;
    exact fun h => entryPoint_min p ( Nat.gcd e n ) ( Nat.gcd_pos_of_pos_left _ he_pos ) h_gcd_lt_e <| fib_dvd_gcd p e n he_div h;
  · exact fun h => dvd_trans ( dvd_fib_entryPoint p hex ) ( Nat.fib_dvd _ _ h )

/-- `p` is a *primitive prime divisor* of `F_n`: it divides `F_n` but none of the
earlier Fibonacci numbers. -/
def IsPrimitive (p n : ℕ) : Prop :=
  p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬ p ∣ Nat.fib k

theorem primitive_iff_entry_eq (p n : ℕ) (hn : 0 < n)
    (hex : ∃ k, 0 < k ∧ p ∣ Nat.fib k) :
    IsPrimitive p n ↔ entryPoint p = n := by
  constructor <;> intro h;
  · apply le_antisymm;
    · obtain ⟨ k, hk₁, hk₂ ⟩ := hex;
      have h_entryPoint_def : entryPoint p = Nat.find (show ∃ k, 0 < k ∧ p ∣ Nat.fib k from ⟨k, hk₁, hk₂⟩) := by
                                                        exact dif_pos ⟨ k, hk₁, hk₂ ⟩;
      exact h_entryPoint_def.symm ▸ Nat.find_min' _ ⟨ hn, h.1 ⟩;
    · exact le_of_not_gt fun h' => h.2 _ ( entryPoint_pos _ hex ) h' ( dvd_fib_entryPoint _ hex );
  · refine' ⟨ _, fun k hk₁ hk₂ => _ ⟩;
    · exact h ▸ dvd_fib_entryPoint p hex;
    · exact entryPoint_min p k hk₁ ( by linarith )

theorem fib_twelve_no_primitive :
    ¬ ∃ p, Nat.Prime p ∧ IsPrimitive p 12 := by
  simp +zetaDelta at *;
  rintro p pp ⟨ hp₁, hp₂ ⟩;
  have := Nat.le_of_dvd ( by decide ) hp₁; interval_cases p <;> norm_num at *;
  · exact absurd ( hp₂ 3 ( by decide ) ( by decide ) ) ( by decide );
  · exact hp₂ 4 ( by decide ) ( by decide ) ( by decide )

/-- Sanity check: `13 ∣ F_7 = 13` and `13` divides no earlier Fibonacci number, so by
`primitive_iff_entry_eq` the entry point of `13` is exactly `7`. -/
example : entryPoint 13 = 7 := by
  have hex : ∃ k, 0 < k ∧ (13 : ℕ) ∣ Nat.fib k := ⟨7, by decide, by decide⟩
  refine (primitive_iff_entry_eq 13 7 (by decide) hex).1 ?_
  refine ⟨by decide, ?_⟩
  intro k hk hk'
  interval_cases k <;> decide

end FibonacciEntryPoints
'''

future_directions = r'''# Future Directions: Fibonacci Entry Points and Primitive Divisors

This cycle formalized the divisibility theory of the *Fibonacci entry point*
(rank of apparition) `α(p) = entryPoint p`, the least `k > 0` with `p ∣ F_k`,
and derived a clean characterization of *primitive prime divisors* of Fibonacci
numbers:

* `fib_dvd_gcd` — the gcd–Fibonacci bridge `p ∣ F_m → p ∣ F_n → p ∣ F_{gcd(m,n)}`.
* `dvd_fib_iff_entry_dvd` — `p ∣ F_n ↔ α(p) ∣ n`.
* `primitive_iff_entry_eq` — `p` is a primitive prime divisor of `F_n` iff `α(p) = n`.
* `fib_twelve_no_primitive` — the classical exception: `F_12 = 144` has no primitive divisor.

These results are the analytic backbone of Carmichael's primitive-divisor theorem,
recast self-containedly against Mathlib. Concrete, falsifiable next steps:

## Direction 1 — Entry point and the Pisano period

The Pisano period `π(p)` (period of `F` mod `p`) is always a multiple of the entry
point `α(p)`, and the quotient `π(p)/α(p) ∈ {1, 2, 4}`. Formalize `α(p) ∣ π(p)` and
the bound on the quotient, building directly on `dvd_fib_iff_entry_dvd`.

The key insight is that the multiplicative *order* of the companion matrix
`[[1,1],[1,0]]` mod `p` is exactly `π(p)`, while `α(p)` is the additive index at which
the off-diagonal entry first vanishes; the quotient measures the order of the
eigenvalue ratio, a unit whose order divides 4. Why now? We already have
`dvd_fib_iff_entry_dvd`, the exact "`α(p) ∣ n ↔ p ∣ F_n`" lever needed to transfer
between the entry point and the period, and Mathlib's `ZMod` matrix-order API makes the
companion-matrix formulation routine.

## Direction 2 — Law of apparition for `p ≡ ±1 (mod 5)`

For an odd prime `p ≠ 5`, the entry point satisfies `α(p) ∣ p - 1` when `p ≡ ±1 (mod 5)`
and `α(p) ∣ p + 1` when `p ≡ ±2 (mod 5)` (the law of apparition). Formalize this
divisibility as a corollary of `dvd_fib_iff_entry_dvd` together with `p ∣ F_{p-(5/p)}`
(a Fibonacci analogue of Fermat's little theorem, where `(5/p)` is the Legendre symbol).

The key insight is that the Binet identity over `ZMod p` turns `F_{p - (5/p)} ≡ 0` into a
statement about whether `5` is a quadratic residue, so the entry-point divisibility is
precisely the Frobenius action on `√5`. Why now? `dvd_fib_iff_entry_dvd` already reduces
the law of apparition to proving the single congruence `p ∣ F_{p ± 1}`, and Mathlib's
quadratic-reciprocity and `legendreSym` machinery supplies the residue dichotomy off the
shelf.

## Direction 3 — Complete the list of Fibonacci exceptions

`fib_twelve_no_primitive` is one of exactly two non-trivial indices (`n = 1, 2, 6, 12`,
with `1, 2` degenerate) where `F_n` lacks a primitive prime divisor (Carmichael 1913).
Prove the converse direction in full: for every `n ∉ {1, 2, 6, 12}`, `F_n` does have a
primitive prime divisor — establishing the complete Carmichael classification for
Fibonacci numbers.
'''

# ---- algorithm code blocks ----
algo_entry_code = '''from typing import Optional

def entry_point(p: int, search_limit: int = 10_000) -> Optional[int]:
    """Least k > 0 with p | F_k (rank of apparition), or None if not found.

    Works on residues mod p only, so arithmetic stays bounded. Terminates within
    the Pisano period (<= 6p by Wall's bound)."""
    if p == 1:
        return 1
    a, b = 0, 1  # a = F_0 mod p, b = F_1 mod p
    for k in range(1, search_limit + 1):
        if b % p == 0:
            return k
        a, b = b, (a + b) % p
    return None
'''

algo_prim_code = '''from typing import List

def fib(k: int) -> int:
    a, b = 0, 1
    for _ in range(k):
        a, b = b, a + b
    return a

def prime_factors(n: int) -> List[int]:
    factors: List[int] = []
    d, m = 2, n
    while d * d <= m:
        if m % d == 0:
            factors.append(d)
            while m % d == 0:
                m //= d
        d += 1
    if m > 1:
        factors.append(m)
    return factors

def entry_point(p: int) -> int:
    if p == 1:
        return 1
    a, b = 0, 1
    k = 1
    while True:
        if b % p == 0:
            return k
        a, b = b, (a + b) % p
        k += 1

def primitive_prime_divisors(n: int) -> List[int]:
    """Primes p with entry_point(p) == n among the prime factors of F_n.

    By the characterization Prim(p, n) <=> entry_point(p) == n, this is exact."""
    fn = fib(n)
    if fn <= 1:
        return []
    return [p for p in prime_factors(fn) if entry_point(p) == n]
'''

viz_code = r'''"""Visualization: a 'divisibility grid' of small primes against Fibonacci indices,
highlighting entry points and the exceptional index n = 12.

Renders a heatmap where cell (p, n) is shaded if p | F_n, with each prime's entry
point marked. Saves to fib_entry_points.png. Requires matplotlib + numpy."""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt


def fib_mod(n: int, p: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, (a + b) % p
    return a


def entry_point(p: int) -> int:
    a, b, k = 0, 1, 1
    while True:
        if b % p == 0:
            return k
        a, b = b, (a + b) % p
        k += 1


def main() -> None:
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
    N = 30
    grid = np.zeros((len(primes), N))
    for i, p in enumerate(primes):
        for n in range(1, N + 1):
            grid[i, n - 1] = 1.0 if fib_mod(n, p) == 0 else 0.0

    fig, ax = plt.subplots(figsize=(12, 5))
    ax.imshow(grid, aspect="auto", cmap="Blues",
              extent=[0.5, N + 0.5, len(primes) - 0.5, -0.5])
    for i, p in enumerate(primes):
        e = entry_point(p)
        ax.scatter([e], [i], s=80, facecolors="none", edgecolors="red", linewidths=2)
    ax.axvline(12, color="orange", linestyle="--", linewidth=2, label="n = 12 (exception)")
    ax.set_yticks(range(len(primes)))
    ax.set_yticklabels([f"p={p}" for p in primes])
    ax.set_xticks(range(1, N + 1))
    ax.set_xlabel("Fibonacci index n")
    ax.set_title("p | F_n  (shaded);  red circle = entry point a(p)")
    ax.legend(loc="upper right")
    fig.tight_layout()
    fig.savefig("fib_entry_points.png", dpi=140)
    print("saved fib_entry_points.png")


if __name__ == "__main__":
    main()
'''

interactive_html = r'''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Fibonacci Entry Point Explorer</title>
<style>
  body { font-family: system-ui, sans-serif; max-width: 760px; margin: 2rem auto; padding: 0 1rem; color: #1a1a1a; }
  h1 { font-size: 1.4rem; }
  .card { border: 1px solid #ddd; border-radius: 10px; padding: 1rem 1.2rem; margin: 1rem 0; background: #fafafa; }
  input[type=number] { width: 6rem; padding: .3rem; font-size: 1rem; }
  button { padding: .4rem .9rem; font-size: 1rem; border-radius: 8px; border: 1px solid #888; background: #fff; cursor: pointer; }
  .result { font-size: 1.05rem; margin-top: .6rem; }
  .hits { font-family: ui-monospace, monospace; color: #1a4f8b; }
  .warn { color: #b34700; font-weight: 600; }
  code { background: #eee; padding: .1rem .3rem; border-radius: 4px; }
</style>
</head>
<body>
<h1>Fibonacci Entry Point Explorer</h1>
<p>The <strong>entry point</strong> &alpha;(p) of an integer p is the least index k with p &nbsp;|&nbsp; F<sub>k</sub>.
By the divisibility law, <code>p | F_n  &hArr;  &alpha;(p) | n</code>, so p divides exactly the Fibonacci
numbers at multiples of its entry point. A prime is a <em>primitive prime divisor</em> of F<sub>n</sub>
exactly when &alpha;(p) = n.</p>

<div class="card">
  <label>Enter an integer p &ge; 2: <input id="p" type="number" min="2" value="7"></label>
  <button onclick="computeEntry()">Find entry point</button>
  <div id="entryOut" class="result"></div>
</div>

<div class="card">
  <label>Enter a Fibonacci index n: <input id="n" type="number" min="1" value="12"></label>
  <button onclick="computePrim()">Primitive divisors of F&#8345;</button>
  <div id="primOut" class="result"></div>
</div>

<script>
function fib(k) {
  let a = 0n, b = 1n;
  for (let i = 0; i < k; i++) { [a, b] = [b, a + b]; }
  return a;
}
function entryPoint(p) {
  const P = BigInt(p);
  if (P === 1n) return 1;
  let a = 0n, b = 1n;
  for (let k = 1; k <= 100000; k++) {
    if (b % P === 0n) return k;
    [a, b] = [b, (a + b) % P];
  }
  return null;
}
function primeFactors(n) {
  let m = n, d = 2n, fs = [];
  while (d * d <= m) {
    if (m % d === 0n) { fs.push(d); while (m % d === 0n) m /= d; }
    d += 1n;
  }
  if (m > 1n) fs.push(m);
  return fs;
}
function computeEntry() {
  const p = parseInt(document.getElementById('p').value, 10);
  const e = entryPoint(p);
  const hits = [];
  for (let n = e; n <= 30; n += e) hits.push(n);
  document.getElementById('entryOut').innerHTML =
    `&alpha;(${p}) = <strong>${e}</strong> &nbsp;(first divides F<sub>${e}</sub> = ${fib(e)}).<br>` +
    `Indices &le; 30 where ${p} | F<sub>n</sub>: <span class="hits">[${hits.join(', ')}]</span>`;
}
function computePrim() {
  const n = parseInt(document.getElementById('n').value, 10);
  const fn = fib(n);
  const prims = [];
  if (fn > 1n) {
    for (const p of primeFactors(fn)) {
      if (entryPoint(Number(p)) === n) prims.push(p.toString());
    }
  }
  let msg = `F<sub>${n}</sub> = ${fn.toString()}. `;
  if (prims.length === 0) {
    msg += `<span class="warn">No primitive prime divisor!</span>`;
    if (n === 12) msg += ` (This is the classical Carmichael exception: 144 = 2&#8308;&middot;3&#178;.)`;
  } else {
    msg += `Primitive prime divisor(s): <span class="hits">${prims.join(', ')}</span>`;
  }
  document.getElementById('primOut').innerHTML = msg;
}
computeEntry();
computePrim();
</script>
</body>
</html>
'''

package = {
    "title": "Close Proofs: Fibonacci Entry Points and Primitive Prime Divisors",
    "domain": "Novelty",
    "description": ("A self-contained divisibility theory of Fibonacci entry points (ranks of "
                    "apparition), deriving the entry-point divisibility law, a characterization of "
                    "primitive prime divisors, and the classical exception F_12 = 144 from a single "
                    "gcd identity."),
    "authors": ["Aristotle (Harmonic)"],
    "date": "2026-06-11",
    "key_results": [
        "gcd bridge: if p | F_m and p | F_n then p | F_{gcd(m,n)}.",
        "Entry-point divisibility law: p | F_n  <=>  entryPoint(p) | n.",
        "A prime is a primitive prime divisor of F_n iff its entry point equals n.",
        "F_12 = 144 has no primitive prime divisor (the classical Carmichael exception).",
    ],
    "keywords": [
        "Fibonacci numbers", "entry point", "rank of apparition",
        "primitive prime divisor", "Carmichael theorem", "gcd identity",
        "Pisano period", "law of apparition",
    ],
    "article": "ARTICLE.md",
    "research_paper": "RESEARCH_PAPER.md",
    "demo": "demo.py",
    "demos": [
        {
            "name": "divisibility_law_demo",
            "description": ("For small primes, lists every index n <= 30 with p | F_n and checks it "
                            "equals the set of multiples of the entry point, confirming "
                            "p | F_n <=> entryPoint(p) | n."),
            "code": demo,
        },
        {
            "name": "twelve_exception_demo",
            "description": ("Factors F_12 = 144 = 2^4 * 3^2 and shows both prime divisors entered "
                            "earlier (entryPoint(2)=3, entryPoint(3)=4), so 144 has no primitive "
                            "prime divisor; contrasts with F_7 = 13."),
            "code": demo,
        },
    ],
    "algorithms": [
        {
            "name": "entry_point_residue_scan",
            "description": ("Computes the Fibonacci entry point alpha(p) = least k>0 with p | F_k by "
                            "scanning the Fibonacci sequence reduced modulo p until the first zero "
                            "residue. Because only residues mod p are stored, each step is O(log p)-bit "
                            "arithmetic, and termination is guaranteed within the Pisano period "
                            "pi(p) <= 6p (Wall's bound), giving O(p) modular additions. This is the "
                            "fundamental primitive of the package: once alpha(p) is known, the full "
                            "divisibility pattern of p (Corollary: multiples of alpha(p)) and the "
                            "primitivity test (alpha(p)==n) follow in O(1) extra work."),
            "pseudocode": ("function ENTRY_POINT(p):\n"
                           "    if p == 1: return 1\n"
                           "    a, b <- 0, 1            # a = F_0 mod p, b = F_1 mod p\n"
                           "    k <- 1\n"
                           "    loop:\n"
                           "        if b == 0: return k # first index with p | F_k\n"
                           "        a, b <- b, (a + b) mod p\n"
                           "        k <- k + 1\n"
                           "    # terminates within the Pisano period of F mod p"),
            "code": algo_entry_code,
        },
        {
            "name": "primitive_prime_divisors",
            "description": ("Lists the primitive prime divisors of F_n, i.e. primes dividing F_n but no "
                            "earlier Fibonacci number. Uses the characterization Prim(p,n) <=> "
                            "alpha(p) == n: it factors F_n (trial division, O(sqrt(F_n))) and keeps "
                            "exactly those prime factors whose entry point equals n. This avoids the "
                            "naive O(n) re-scan of all earlier Fibonacci numbers per prime, replacing "
                            "it with one entry-point computation per prime factor."),
            "pseudocode": ("function PRIMITIVE_PRIME_DIVISORS(n):\n"
                           "    f <- F_n\n"
                           "    if f <= 1: return []\n"
                           "    result <- []\n"
                           "    for each prime q dividing f:\n"
                           "        if ENTRY_POINT(q) == n:\n"
                           "            append q to result\n"
                           "    return result"),
            "code": algo_prim_code,
        },
    ],
    "visualizations": [
        {
            "name": "divisibility_grid_heatmap",
            "description": ("A heatmap over primes p (rows) and Fibonacci indices n (columns) shading "
                            "cells where p | F_n, with each prime's entry point circled in red and the "
                            "exceptional index n=12 marked, visually revealing the periodic 'striping' "
                            "predicted by the divisibility law."),
            "code": viz_code,
        },
    ],
    "interactive_demos": [
        {
            "title": "Fibonacci Entry Point Explorer",
            "description": ("Type any integer p to see its entry point and the indices where it divides "
                            "Fibonacci numbers, or type an index n to see the primitive prime divisors "
                            "of F_n (and discover that n=12 has none). Runs entirely in the browser with "
                            "BigInt arithmetic."),
            "html": interactive_html,
        },
    ],
    "lean_proofs": lean_proofs,
    "future_directions": future_directions,
    "modules": {"demo": demo},
    "lean_files": ["Catalog/Speculative/AutoResearch/FibonacciEntryPoints.lean"],
}

(HERE / "PACKAGE.json").write_text(json.dumps(package, indent=2, ensure_ascii=False))
print("wrote PACKAGE.json")


"""Fibonacci Entry Points and Primitive Prime Divisors — numerical demonstrations.

This self-contained script illustrates the four central results of the package:

  1. fib_dvd_gcd        : p | F_m  and  p | F_n   =>   p | F_gcd(m,n)
  2. dvd_fib_iff_entry  : p | F_n  <=>  entry_point(p) | n
  3. primitive_iff_entry: Prim(p, n)  <=>  entry_point(p) == n
  4. fib_twelve         : F_12 = 144 has no primitive prime divisor.

Run with:  python demo.py
"""

from __future__ import annotations

from math import gcd
from typing import Dict, List, Optional


# --------------------------------------------------------------------------- #
# Core arithmetic (all functions inlined, fully type hinted)                   #
# --------------------------------------------------------------------------- #
def fib(k: int) -> int:
    """Return the k-th Fibonacci number with F_1 = F_2 = 1, F_0 = 0."""
    if k < 0:
        raise ValueError("index must be non-negative")
    a, b = 0, 1
    for _ in range(k):
        a, b = b, a + b
    return a


def entry_point(p: int, search_limit: int = 10_000) -> int:
    """Least k > 0 with p | F_k (the rank of apparition), or 0 if none found.

    Scans Fibonacci residues modulo p so the integers stay small; terminates
    within the Pisano period (<= 6p by Wall's bound)."""
    if p == 1:
        return 1
    a, b = 0, 1  # a = F_0 mod p, b = F_1 mod p
    for k in range(1, search_limit + 1):
        if b % p == 0:
            return k
        a, b = b, (a + b) % p
    return 0


def prime_factors(n: int) -> List[int]:
    """Return the sorted list of distinct prime factors of n (n >= 1)."""
    factors: List[int] = []
    d = 2
    m = n
    while d * d <= m:
        if m % d == 0:
            factors.append(d)
            while m % d == 0:
                m //= d
        d += 1
    if m > 1:
        factors.append(m)
    return factors


def is_primitive_prime_divisor(p: int, n: int) -> bool:
    """True iff p | F_n but p divides no earlier Fibonacci number F_1..F_{n-1}."""
    if fib(n) % p != 0:
        return False
    return all(fib(k) % p != 0 for k in range(1, n))


def primitive_prime_divisors(n: int) -> List[int]:
    """All primes p that are primitive prime divisors of F_n."""
    fn = fib(n)
    if fn <= 1:
        return []
    return [p for p in prime_factors(fn) if is_primitive_prime_divisor(p, n)]


# --------------------------------------------------------------------------- #
# Demonstrations                                                               #
# --------------------------------------------------------------------------- #
def demo_gcd_bridge() -> None:
    """Result 1: common divisors of F_m, F_n divide F_gcd(m,n); also
    gcd(F_m, F_n) = F_gcd(m,n)."""
    print("=" * 64)
    print("1. gcd-Fibonacci bridge:  gcd(F_m, F_n) = F_gcd(m,n)")
    print("=" * 64)
    pairs = [(12, 18), (10, 15), (8, 12), (9, 6)]
    for m, n in pairs:
        lhs = gcd(fib(m), fib(n))
        rhs = fib(gcd(m, n))
        ok = "OK" if lhs == rhs else "FAIL"
        print(f"  gcd(F_{m}, F_{n}) = gcd({fib(m)}, {fib(n)}) = {lhs}"
              f"   |   F_gcd({m},{n}) = F_{gcd(m, n)} = {rhs}   [{ok}]")
    print()


def demo_divisibility_law() -> None:
    """Result 2: p | F_n  <=>  entry_point(p) | n."""
    print("=" * 64)
    print("2. Divisibility law:  p | F_n  <=>  entry_point(p) | n")
    print("=" * 64)
    for p in [2, 3, 5, 7, 11, 13]:
        e = entry_point(p)
        hits = [n for n in range(1, 31) if fib(n) % p == 0]
        predicted = [n for n in range(1, 31) if n % e == 0]
        ok = "OK" if hits == predicted else "FAIL"
        print(f"  p={p:2d}: entry_point={e:2d}  | indices with p|F_n (<=30): {hits}  [{ok}]")
    print()


def demo_primitive() -> None:
    """Result 3: Prim(p, n)  <=>  entry_point(p) == n."""
    print("=" * 64)
    print("3. Primitivity:  Prim(p, n)  <=>  entry_point(p) == n")
    print("=" * 64)
    for n in range(1, 16):
        prims = primitive_prime_divisors(n)
        # cross-check via entry point
        check = all(entry_point(p) == n for p in prims)
        tag = "OK" if check else "FAIL"
        label = ", ".join(map(str, prims)) if prims else "(none)"
        print(f"  F_{n:2d} = {fib(n):4d}   primitive prime divisors: {label}   [{tag}]")
    print()


def demo_twelve_exception() -> None:
    """Result 4: F_12 = 144 has NO primitive prime divisor."""
    print("=" * 64)
    print("4. The exception:  F_12 = 144 has no primitive prime divisor")
    print("=" * 64)
    n = 12
    fn = fib(n)
    print(f"  F_12 = {fn} = 2^4 * 3^2,  prime factors {prime_factors(fn)}")
    for p in prime_factors(fn):
        e = entry_point(p)
        print(f"    prime {p}: entry_point = {e}  (first divides F_{e} = {fib(e)})"
              f"  -> primitive at 12? {is_primitive_prime_divisor(p, 12)}")
    prims = primitive_prime_divisors(12)
    print(f"  primitive prime divisors of F_12: {prims if prims else '(none)'}")
    print(f"  Carmichael exception confirmed: {prims == []}")
    print()

    # Contrast with F_7 = 13, a textbook primitive divisor.
    print("  Contrast — F_7 = 13:")
    print(f"    entry_point(13) = {entry_point(13)}, "
          f"primitive at 7? {is_primitive_prime_divisor(13, 7)}")
    print()


def entry_point_table(limit: int = 40) -> Dict[int, int]:
    """Build {prime: entry_point} for primes up to `limit`."""
    primes = [p for p in range(2, limit + 1) if prime_factors(p) == [p]]
    return {p: entry_point(p) for p in primes}


def main() -> None:
    demo_gcd_bridge()
    demo_divisibility_law()
    demo_primitive()
    demo_twelve_exception()

    print("=" * 64)
    print("Appendix: entry points of small primes")
    print("=" * 64)
    table = entry_point_table(40)
    print("  " + "  ".join(f"a({p})={e}" for p, e in table.items()))


if __name__ == "__main__":
    main()
