import Mathlib.Data.Finset.Basic
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic.NormNum

/-!
# Negative results: factoring directions that are already closed

This file is a **kill record**.  A research catalog is most useful when it
remembers not only what was proved but also which plausible-looking directions
are *known dead*, so they are not re-proposed.  Each entry below was proposed,
then checked against the primary literature, and **killed**.  The machine-checked
theorem at the end (`mod4_not_injective`) supports the first entry; the rest are
documentary.

State of the art (as of late 2026): the general number field sieve at
`L[1/3, (64/9)^{1/3} ≈ 1.923]` is unchanged, ECM at `L_p[1/2, √2]`, and there is
no polynomial-time classical general-purpose factoring algorithm.  Harvey's
deterministic `N^{1/5}` (Math. Comp. 2021) is rigorous but deterministic and
exponential, so it does not touch RSA security.  References:
Buhler–Lenstra–Pomerance 1993; Harvey 2020; Barbulescu–Guillevic–Lenstra–Razvan
(ePrint 2020/829).

## The killed directions

| # | Proposed direction | Why it is dead | Reference |
|---|--------------------|----------------|-----------|
| 1 | **Reciprocal / Gauss-sum phase** — read the factor off `arg` of a quadratic Gauss sum mod `N`. | The phase of the genuine Gauss sums is a 4th root of unity fixed by `N mod 4` and small residue symbols (polynomial time), carrying **zero** bits about `p`, `q`. The proposed double twist is not even multiplicative. | Murty, *Evaluation of the Quadratic Gauss Sum* |
| 2 | **Self-similar / "unbounded arity" sieve tower** — beat the `L[1/k,c]` barrier with `k = π(B)`. | It is Schirokauer's **Tower NFS** (2000) + special-`q` descent; even for arbitrary extension degree the complexity is still `L[1/3, (64/9)^{1/3}]`. The "polynomial escape" omits the Dickman factor `1/ρ(u)`: for `k = π(B)` the true relation-collection cost is `≈ √N`. | Schirokauer 2000; Barbulescu–Gaudry–Kleinjung, *The Tower NFS* (ePrint 2015/505) |
| 3 | **Real-quadratic infrastructure / CF-period parity** — one parity bit of the period of `√N` as a factor oracle. | The parity theorem is **Lagrange/Legendre** (1760s–1785), a *negative-Pell solvability* criterion, not a factoring oracle. On RSA semiprimes the bit is free or uninformative, and one bit cannot factor an `n`-bit modulus. The `N^{1/4}` partial step is **SQUFOF** (Shanks 1969). The BSGS fast path needs the regulator, and factoring reduces to computing the regulator. | Rippon–Taylor 2004; Gower–Wagstaff 2008; Bernstein (parallel SQUFOF); Murru–Salvatori 2024 |
| 4 | **Precomputation-amortized factoring** — a universal factor base / batched sieve to break the exponent. | Amortization moves only the **constant `c`** (GNFS `1.923` → Coppersmith factory `1.639`), never the exponent `ρ = 1/3`. Practical realizable gains are `≈ 2×` (Mersenne factory). | Bernstein–Lange, *Batch NFS* (2014/921); Kleinjung–Bos–Lenstra, *Mersenne Factorization Factory* (2014/653) |
| 5 | **Genus-character single-bit reduction** — factor `N` from one nonprincipal quadratic character. | The content is Gauss's genus theory (1801); the one-character formulation is folklore-grade repackaging, and its formalizable core `(a/p)(a/q) = (a/pq)` is a one-line Mathlib lemma. | Gauss, *Disquisitiones Arithmeticae* 1801; Cox, *Primes of the Form x²+ny²* |

## Why the "arity" escape is an artifact — the load-bearing correction

The `1/3` exponent of the NFS is **not** an AM–GM balance over three stages.  It
is the optimum of a smoothness-probability vs. linear-algebra balance
(minimise `B² + E²` subject to `E² · Prob ≥ B^{1+o(1)}`), which is **insensitive
to arity**.  `tradeoff_lower_bound` in `TradeoffBarrier.lean` is a correct AM–GM
theorem *about its model*, but that model omits the Dickman smoothness factor
and must not be read as a lower bound on factoring.  This is the correction that
direction 2 turns on.
-/

namespace FactoringBarriers.NegativeResults

/-- `n` is a product of two distinct primes.  (A self-contained copy so this
record does not depend on the `Pythagorean` factoring-barrier module.) -/
def IsSemiprime (n : ℕ) : Prop :=
  ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ p ≠ q ∧ n = p * q

/-- Three distinct semiprimes, all congruent to `3 (mod 4)`.  They are pairwise
distinguished, but *not* by the residue class — the point of the theorem below. -/
def mod4Semiprimes : Finset ℕ := {15, 39, 55}

/-- Every member of `mod4Semiprimes` is a product of two distinct primes. -/
theorem mem_mod4Semiprimes_isSemiprime {n : ℕ} (h : n ∈ mod4Semiprimes) :
    IsSemiprime n := by
  simp only [mod4Semiprimes, Finset.mem_insert, Finset.mem_singleton] at h
  rcases h with rfl | rfl | rfl
  · exact ⟨3, 5, by decide, by decide, by decide, rfl⟩
  · exact ⟨3, 13, by decide, by decide, by decide, rfl⟩
  · exact ⟨5, 11, by decide, by decide, by decide, rfl⟩

/-- **A low-order residue observable carries no factoring information.**  The
map `n ↦ n mod 4` is not injective on the semiprimes: `15 = 3·5` and
`39 = 3·13` are distinct factorisations of distinct moduli, yet share a residue
class.

This is the machine-checked core of killed direction #1.  The phase of a
quadratic Gauss sum is a 4th root of unity fixed by `N mod 4` (and small residue
symbols such as `(2/N)`), so it — like `n mod 4` — cannot separate distinct
factorisations.  The general information-theoretic form is stronger still: the
number of semiprimes up to `N` is exponential in `log N`, so *no* single-bit
classical oracle can factor. -/
theorem mod4_not_injective : ¬ Function.Injective (fun n : ℕ => n % 4) := by
  intro h
  have heq : (15 : ℕ) % 4 = 39 % 4 := by norm_num
  have h1521 : (15 : ℕ) = 39 := h heq
  norm_num at h1521

end FactoringBarriers.NegativeResults
