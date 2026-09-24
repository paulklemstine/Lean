import Mathlib.Data.Finset.Basic
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# Negative results: factoring directions that are already closed

This file is a **kill record**.  A research catalog is most useful when it
remembers not only what was proved but also which plausible-looking directions
are *known dead*, so they are not re-proposed.  Each entry below was proposed,
then checked against the primary literature, and **killed**.  Most are
documentary; the machine-checked theorems at the end support entries 1, 7 and
11 (`mod4_not_injective`, `known_leak_maximized_at_balanced`,
`coldboot_noise_below_capacity`).  Entries 12–13 (the Berggren tree) rest on
theorems already proved in the `BerggrenModular` / `BerggrenSpectral` modules,
which are deliberately not re-imported here to keep this file self-contained.
Entries 14–17 (Gu–Martin) are documentary against arXiv:1709.02411; entry 17's
core fact ("a semiprime is squarefree") is elementary but is left documentary
because formalising it needs `Mathlib.Algebra.Squarefree.Basic`, which pulls in
`DecompositionMonoid ℕ` -- too heavy for this file's narrow-import discipline.

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
| 6 | **"AGM conjecture" as a witness that `n/4` is optimal** — cite a named conjecture to certify the partial-key barrier. | **A phantom citation.** Attributed variously to Alvarez–Gruber–Maier and to a Coppersmith–Howgrave–Graham–Unger CRYPTO 2004 paper, it has zero trace on Google Scholar, Crossref, the arXiv API, or a full IACR cryptodb sweep (≈1800 records, 1996–2007); the "AGM conjecture" hits that exist are the *symmetrized arithmetic–geometric mean inequality* in operator theory. Use the **proved** bounds instead: `X ≤ N^{β²}` (ePrint 2022/271, Thm 2) and `γ₁+…+γ_n < β²` (ePrint 2014/343, Thm 7). | see `RESEARCH.md` §4d-v |
| 7 | **"`1/3` of the bits of `p` factors RSA"** — a sub-`n/4` partial-key crossing. | The claim comes from Takayasu–Kunihiro's asymptotic PKE curve and was **refuted by the very paper that introduced the `1/3`**: May–Nowakowski–Sarkar show the claim would be "a major improvement over Coppersmith's famous factoring with hint", then give "strong experimental evidence that TK fails". Separately, the MNS "1/3" itself is a leak of the **CRT exponents `d_p,d_q`**, not of `p` — absolute known-bit budget is still `N^{1/4}`. | Takayasu–Kunihiro ePrint 2016/1056, 2018/516; May–Nowakowski–Sarkar ePrint 2022/271 §1, §5 |
| 8 | **Memcomputing / self-organizing-gate factoring** — an *attractor-based, chaos-avoiding* analog device, so noise cannot corrupt a contracting orbit. | **Killed by its own follow-up.** The headline "sub-second 2048-bit" is a **low-degree polynomial extrapolation** from a tuned ≤300-bit range; the largest actual *run* is ~60 bits and there is no silicon. Nguyen et al. show the contraction the design relies on is **destroyed by noise**, so "attracting ⇒ robust ⇒ large `N`" fails in-model. | Sharp et al. arXiv:2309.08198; Nguyen et al. arXiv:2506.14928 (*Chaos* 2026) |
| 9 | **Resonance / peak-position factor encoding** — read `p` off a resonance whose position encodes the divisor. | **Two independent kills.** (i) *Continuity:* factoring is **discontinuous** — adjacent `N` have wildly different factors — so **no smooth flow can output `p(N)` continuously**; there is no continuous resonance to position-encode. (ii) *Reduction:* the discrete-instantiation is the already-dead **RSDT** mechanism, which collapses to trial division. | see `RESEARCH.md` §4a |
| 10 | **"Noisy Coppersmith"** — a rigorous noise-tolerant form of `X ≤ N^{β²}`, e.g. `X ≤ f(N,e)` for `e` errors in the known bits of `p`. | **A category error: no attack ever feeds noisy bits to the lattice.** Halderman et al. (CCS 2008 §5.4) and Paterson–Polychroniadou–Sibborn (ASIACRYPT 2012 §2) *both* branch bit-by-bit first and invoke Coppersmith only on **clean, already-recovered** bits — it is a final step, never the noise-robust one. The multivariate ACD-with-error extension is **heuristic on its face** (Cohn–Heninger, ePrint 2011/437: "we cannot rigorously prove that it always works"). | see `RESEARCH.md` §4e |
| 11 | **"Noise *rate* is what makes cold-boot RSA hard"** — the premise of the old noisy-leak framing. | **Backwards: the noise rate is in *surplus*.** Real remanence decay leaves **≥90% of bits correct** (Halderman measured `δ` = 4–10%), far cleaner than the ~20–24% error the whole-key methods can barely handle — see `coldboot_noise_below_capacity` below. The genuine difficulty is the **channel asymmetry** (unidirectional 1→0 decay), on which HS/HMM **fail outright**; only PPS's maximum-likelihood decoder works. | see `RESEARCH.md` §4e |
| 12 | **The Berggren / Pythagorean triplet tree as a factoring device** — the tree is exponentially large (`3^k` states) and variable-depth, which looked like an escape from the fixed-construction barriers. | **The tree is `N`-independent** (root `(3,4,5)`, fixed integer `bergMatrix`; no integer-development quantity references the modulus), so its control word, nodes and continuous invariants carry **zero bits about `p`**. And `SmoothnessEscape.lean` shows the only real escape from the polynomial barrier is a *growing parameter tuned to a group-theoretic quantity of `p`* — **depth `k` is not such a parameter**, so the `3^k` size is cosmetic. `N` enters by only three channels, all dead: gcd (trial division, `α=1`, plus the guidance null), multiplicative order (row 13), or not at all. | `RESEARCH.md` §4f; `BerggrenModular/Core.lean`, `TrialDivisionEquivalence.lean` |
| 13 | **Berggren spectral resonance as a new factoring method** (`berg_resonance_factorization`, `M₂` powers mod `p`). | **It is Pollard `p±1`.** `berg_two_resonance_mod_eight` proves `ord_p(M₂) ∣ p ∓ 1` (sign by `p mod 8`), so the sweep `gcd(M₂^k − 1, N)` splits `N` exactly when `p ∓ 1` is `B`-smooth — the Chevalley–Wielandt matrix form of `p+1`, with base `M₂`. `L[1/2]`-class, **dominated by the NFS**. Upgrades the catalog's older "circular" verdict to "circular *and* classically dominated." | `BerggrenSpectral/HyperbolicResonance.lean`, theorem `berg_two_resonance_mod_eight` |
| 14 | **Aim the modular-curve route at the Hecke *newform* count `B(k,N)` instead of the automorphic count `A(k,N)`** — `B` is the more "concrete" of the two. | **A fast `B` buys nothing for factoring.** `H(k,N) = G(k,N) − B(k,1)` is also factorization-free, and `H(k,N) = B(k,N)` **iff `N` is prime** (Gu–Martin Cor. 9, `N ≥ 92`) — so fast `B` is a **primality test**, already in `P` via AKS/ECPP. The factoring reduction is **`A`-specific**: Thm. 10 needs **two `A`-values plus one `B`-value**, not `B` alone. | Gu–Martin arXiv:1709.02411, Cor. 9, Thm. 10; `RESEARCH.md` §4c-iii |
| 15 | **Tune the weight `k` of the modular-curve count to dodge the factorization** — larger `k` might dilute the index term. | **`k` is irrelevant, and `k = 2` is the worst case.** The multiplicative core `s*₀(N)`, `ν*∞(N)`, `ν*₂(N)`, `ν*₃(N)` — exactly where the factorization lives — is **`k`-independent**; `k` enters only the constants `c₂(k)` (period 4) and `c₃(k)` (period 3). Gu–Martin accept **any** positive even `k` (Cor. 4 for `N ≥ 10`; Thm. 8 / Cor. 9 for `N ≥ 92`). Worse, the main term is `(k−1)N/12 · s*₀(N)`, so **larger `k` is more dominated** by the factorization-encoding index; the exception lists (Cor. 31's nine `(k,p)` pairs) show small `k` is where the closed forms degenerate. | Gu–Martin arXiv:1709.02411, Props. 15/29; `RESEARCH.md` §4c-iii |
| 16 | **"A cheap *Oesterlé* upper bound on `g(X₀(N))` would feed Cor. 4."** | **Dead on citation, and the soft target is real.** The only thing called the Oesterlé bound in circulation is the **Ihara–Oesterlé (Weil–Oesterlé) *point-count* bound** on `#C(ℱ_q)` in terms of genus — a *different object*. **No factorization-free upper bound on `g(X₀(N))` exists.** Three related phantoms: "Cremona–Odoni, *Some remarks on the Oesterlé bound*, IJM 5 (1994) 147–154" (those pages belong to a Ye article, DOI `10.1142/s0129167x94000073`); "Cremona–Odoni, *Computing the genus of `X₀(N)`*"; "Cremona, *Algorithmic invariants for elliptic curves*" (his book is *Algorithms for modular elliptic curves*, CUP 1992). "Oesterlé, Invent. Math. 73 (1983) 273–302" is **uncorroborated**; use **Cohen–Oesterlé, LNM 627 (1977) 69–78**, which is what Sage actually implements. | `RESEARCH.md` §4c-iii; Sage `sage.modular.dims` docs |
| 17 | **Use Gu–Martin's squarefreeness test (Cor. 4) to break RSA** — `A = G` iff `N` is squarefree, so a fast count decides it. | **Tautological on a semiprime.** `N = pq` with `p ≠ q` prime is **squarefree by definition**, so the test returns "squarefree" with no computation and yields **zero** bits about `p`. *(Elementary, and left documentary: formalising it needs `Mathlib.Algebra.Squarefree.Basic`, which drags in `DecompositionMonoid ℕ` — too heavy for this file's narrow-import discipline.)* Cor. 4 is the right statement of the *general* obstruction and is why Gu–Martin, who treat arbitrary `N`, lead with it — but for RSA the squarefull part is `D = 1`, `φ(D)` is trivial, and the real signal is the multiplicative term `s*₀(N)` (which encodes `ω(N)`), reached through the **two-weight linear system**, not through squarefreeness. | `RESEARCH.md` §4c-iii; Gu–Martin arXiv:1709.02411 Cor. 4 |
| 18 | **Apply the Allender–Saks–Shparlinski parity-of-`ω` `AC⁰[p]` lower-bound technique to `Ω` (prime factors counted *with* multiplicity)** — this survey's own recommended circuit-lower-bound target, `Ω ∉ uniform TC⁰`. | **The one published technique provably does not transfer, and the target is also unlinked to factoring.** The ASS reduction reads `Mod_p(x) = 0 ⟺ ω(x)+1 ≡ ω(px) (mod 2)`, so the parity oracle on `{x, px}` **flips iff `p ∣ x`**. For `Ω` the increment is `Ω(px) = Ω(x) + 1` **unconditionally** (`p` prime), so the parity oracle is **constant** on `{x, px}` and recovers nothing about `p ∣ x`. Separately, the link to factoring is **believed, not proven**: Du & Volkovich (FSTTCS 2021) say so in as many words and **no poly-time reduction in either direction between `FACTOR` and `Ω` is known**, so `Ω ∉ TC⁰` would not be a factoring lower bound. **Corrected target: `spf(N) ∉ DLOGTIME-uniform TC⁰`**, which is `≡ₚ FACTOR` by definition. | ASS, *A Lower Bound for Primality*, CCC 1999, DOI `10.1109/CCC.1999.766257`; Du & Volkovich, FSTTCS 2021, DOI `10.4230/LIPIcs.FSTTCS.2021.17`; `RESEARCH.md` §8.4 |

## The `n/4` partial-key barrier, and where the square comes from

For a factor `p ≈ N^β` the **proved** univariate bound is `X ≤ N^{β²}`: `n/4`
bits of a balanced modulus is *half* of `p`'s bits, not a quarter.  The exponent
is not monomial-counting and not root-counting over `F_p` — the polynomial is
univariate, so lattice rank is independent of degree.  It is the
**determinant-vs-modulus enabling condition** on the shift-polynomial lattice:
the `N^{max(0,t−i)}` factors buy vanishing modulus `N^{βm²}` but cost
`N^{β²m²/2}` in the determinant, and the ratio `t²/(m(m+1)) → β²` is the whole
exponent.  The theorem `known_leak_maximized_at_balanced` below machine-checks the
consequence: the required leakage `(β − β²)n` is **maximized at `β = 1/2`**,
where it equals `n/4`.  Balance is exactly what makes the barrier worst.

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

/-- **The partial-key leakage requirement is maximised at the balanced modulus.**
For a factor `p ≈ N^β` the proved univariate bound `X ≤ N^{β²}` requires
`(β − β²)n` *known* bits, and this is at most `n/4`, with equality exactly at
`β = 1/2`.

The content is the completed square `4(β − β²) = 1 − (2β − 1)² ≤ 1`, i.e.
`β − β² ≤ 1/4` because `(2β − 1)² ≥ 0`.  So the `n/4` barrier is a statement
about the **balanced** case specifically: every `β < 1/2` (an unbalanced `N`)
needs *strictly* fewer than `n/4` bits.  This is the machine-checked core of
`RESEARCH.md` §4d-iii — balance is what maximises the required leakage, which is
why the balanced RSA modulus is the worst case. -/
theorem known_leak_maximized_at_balanced (β : ℝ) (n : ℝ) (hn : 0 ≤ n) :
    (β - β * β) * n ≤ n / 4 := by
  have hsq : 0 ≤ (2 * β - 1) ^ 2 := sq_nonneg (2 * β - 1)
  nlinarith

/-- The bound is **attained** at the balanced modulus `β = 1/2`: there the
required leakage is exactly `n/4`. -/
theorem known_leak_attained_at_balanced (n : ℝ) : ((1 / 2 : ℝ) - (1 / 2 : ℝ) ^ 2) * n = n / 4 := by
  ring

/-- **Real cold-boot noise is in surplus, not scarce** — the arithmetic that
kills killed direction #11.

Halderman et al. measured remanence decay on real hardware at `δ ≤ 1/10` for
RSA (2048-bit keys: `δ = 4%` and `6%`; 512-bit primes: `δ = 10%`), leaving at
least `9/10` of the key bits correct.  The whole-key erasure recovery of
Heninger–Shacham needs only `1/5` of the bits known — the capacity figure is
`0.20` (their heuristic analysis claims `0.27`, the formal threshold
`2 − 2^{4/5} ≈ 0.2589`; take the most conservative, `1/5`).

So the observed clean fraction *strictly exceeds* the fraction the best
whole-key method needs to have known.  The noise rate is therefore **not** the
binding constraint on cold-boot RSA recovery: the binding constraints are the
leak *amount* and the channel *asymmetry*.  This is the numeric core of
`RESEARCH.md` §4e's second kill. -/
theorem coldboot_noise_below_capacity : (1 : ℝ) - 1 / 10 > 1 / 5 := by
  norm_num

end FactoringBarriers.NegativeResults
