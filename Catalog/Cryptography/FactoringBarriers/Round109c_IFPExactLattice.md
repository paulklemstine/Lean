# Round 109c — the exact 2-modulus IFP lattice (Feng–Nitaj–Pan / May–Ritzenhofen)

> ⚠️ **Framing corrected in round 109d.** The bound `γ > 4α(1−√α)` reported here is
> the **GIFP** bound (shared bits at arbitrary/differing positions). For the plain
> **LSB** case the sharpest known bound is the smaller `γ > 2α − 2α²` (Lu et al.
> 2016). So `4α(1−√α)` is **not** the best-known IFP bound; it is best for the
> generalized setting. Also, the oracle reveals only the relation
> `p₁ ≡ p₂ (mod 2^t)` (confirmed against the primary source). Read `109d` for the
> full verified progression and the authors' own open gap (`4α(1−√α) → 2α−2α²`).

**2026-10-04. NO new factoring algorithm claimed.** This round implements, from
the primary source, the **exact** 2-modulus lattice behind the subtle
Implicit-Factorization bound, and records a **critical correction** to the premise
I used in round 109b. The lattice is implemented faithfully and verified to build
and reduce; **end-to-end recovery is not claimed** (it needs the paper's Gröbner
step, which this environment cannot run).

Empirical companion: `Experiments/UMWWindow/ifp_fnp.py` (deterministic,
`out_fnp.txt`).

---

## 1. The correction (this is the round's real content)

In round 109b I assumed the IFP hint was **`z = p₁ − p₂`** (an approximation to
`p₁`). **That is wrong.** The May–Ritzenhofen oracle gives **only the relation**

$$ p_1 \equiv p_2 \pmod{2^t}, $$

i.e. `p₁ − p₂` is a *known-to-be-large* multiple of `2^t`, and the **shared value
`M₀ = p₁ mod 2^t` is never revealed**. This is exactly what makes IFP *implicit* —
the attacker never learns any bit of `p₁` directly. The real construction:

* `p₁ = M₀ + x₂·2^{γn}`, `p₂ = M₀ + x₄·2^{γn}` (small `x₂, x₄`; `γn` shared bits).
* Multiply `N₁ = p₁q₁` by `q₂` and eliminate `M₀` via `N₂ = p₂q₂` to get the
  **bivariate** polynomial (Feng–Nitaj–Pan's `f`, degenerating to May–Ritzenhofen
  at `β₁ = β₂ = 0`):
  $$ f(x,y,z) = xz + 2^{(\beta_2+\gamma)n}\,yz + N_2, $$
  whose root `(x₁2^{(\beta_2-\beta_1)n} − x₃,\; x₂ − x₄,\; q₂)` lies modulo the
  **unknown** divisor `2^{(\beta_2-\beta_1)n}·p₁`, with small unknowns `(x,y,z)`.
* Shift polynomials (FNP, verbatim):
  `g_{i,j}(x,y,z) = (yz)^j f(x,y,z)^i (2^{(\beta_2-\beta_1)n})^{m-i} N₁^{max(τ-i,0)}`,
  `0 ≤ i ≤ m`, `0 ≤ j ≤ m−i`; lattice dimension `ω = (m+1)(m+2)/2`.

## 2. The threshold (verified)

Feng–Nitaj–Pan's optimisation of the LLL condition gives, for `k = 2` moduli,

$$ \boxed{\ \gamma\ >\ 4\alpha\bigl(1-\sqrt{\alpha}\bigr)\ } \qquad\text{provided } \alpha+\gamma\le 1, $$

where `α` is the bit-fraction of the cofactor `q`. The script checks this curve
and confirms a synthetic instance (`α = 0.1`, `γ = 0.4`, threshold `0.274`) sits
above it, with the lattice building and LLL-reducing cleanly (15×25 basis).

## 3. Why no end-to-end result is claimed

The recovery extracts `q₂` from the reduced basis via a **Gröbner-basis
computation** (FNP's Assumption 1 — the reason the whole line is labelled
*heuristic*). This environment has no Gröbner engine for the reduced multivar
system, and — per the round-109b lesson — I will **not** ship a lattice whose
recovery I cannot validate end-to-end. The script explicitly states the recovery
is **not claimed**.

## 4. Honest scope

* **The construction and threshold are implemented and recorded faithfully** from
  the primary source (Feng–Nitaj–Pan arXiv:2304.08718 / SAC 2023; degenerates to
  May–Ritzenhofen PKC'09).
* **The key correction** — the IFP oracle reveals only `p₁ ≡ p₂ (mod 2^t)`, never
  `p₁ − p₂` — invalidates the premise of round 109b and is the round's substantive
  contribution to the record.
* **Not claimed:** a verified end-to-end IFP factorisation from the lattice. The
  round-109 **polynomial-time corollary** (exact shared part known, `w ≥ α`)
  remains the verified result; the subtle 2-modulus **heuristic** line is
  documented but not re-derived here.

**Next attack (if continuing IFP).** Add a Gröbner step (sympy/singular/Macaulay2
or the paper's own code) to complete the recovery, then verify the `γ > 4α(1−√α)`
threshold empirically — a concrete, well-posed target that the round-97f lattice
infrastructure can support.