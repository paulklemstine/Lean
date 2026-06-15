
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   **Must be fully self-contained and publishable without any external
   references.** State every theorem, result, and definition inline —
   do NOT use @file references or point to other files. A reader with
   only this article must understand every result without looking elsewhere.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work.
   **Must be fully self-contained and publishable quality without any
   external references.** State every theorem, lemma, and definition
   inline with its full mathematical statement and proof sketch. Do NOT
   use @file references or reference other files. A reader with only this
   paper must be able to follow every result from start to finish.
3. **RESEARCH_PAPER.tex** (NEW) — A clean, compilable LaTeX version of
   the paper that mirrors the content of RESEARCH_PAPER.md. Use standard
   amsmath/amsart or article class, define all theorems inline, and make
   it suitable for direct PDF compilation with `pdflatex`. This is the
   publishable artifact.
4. **demo.py** — Numerical examples demonstrating the key results.
   Self-contained Python, type hints, all functions inlined.
4. **PACKAGE.json** — Single JSON bundling all of the above, with this schema:

```json
{
  "title": "Human-Readable Package Title",
  "domain": "Algebra|Applications|Bridges|Computation|Cryptography|EML|Geometry|Logic|MachineLearning|Novelty|Physics|Pythagorean|Shared|Tropical",
  "description": "1-2 sentence description of the package",
  "authors": ["Author Name"],
  "date": "YYYY-MM-DD",
  "key_results": ["Key result 1", "Key result 2"],
  "keywords": ["keyword1", "keyword2"],
  "article": "ARTICLE.md",
  "research_paper": "RESEARCH_PAPER.md",
  "research_paper_tex": "RESEARCH_PAPER.tex",
  "demo": "demo.py",
  "demos": [
    {"name": "Descriptive and Professional Title of the Python Demo", "description": "A comprehensive, high-quality description of what this Python demo calculates and shows mathematically.", "code": "# full Python source..."}
  ],
  "algorithms": [
    {
      "name": "Formal Mathematical Title of the Algorithm",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
  ],
  "visualizations": [
    {"name": "Descriptive Visualization Title", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Beautiful Math-Rich Interactive Widget Title", "description": "Detailed description of the interactive widget and what users can explore.", "html": "<!DOCTYPE html><html>...</html>"}
  ],
  "lean_proofs": "LEAN_FILE_CONTENT_OR_PLACEHOLDER",
  "future_directions": "FUTURE_DIRECTIONS_CONTENT",
  "modules": {"demo": "# full demo.py source..."},
  "lean_files": ["Catalog/Domain/Package/File.lean"]
}
```

**CRITICAL**: The `demos`, `algorithms`, `visualizations`, and
`interactive_demos` fields MUST be arrays of objects with the
exact structure shown above. Do NOT use placeholder strings like
"MISSING" — either include real content or omit the field entirely.

### DO NOT OUTPUT:
- NO new `.lean` files
- NO new theorem proofs
- NO changes to the existing Lean 4 source
- NO `FUTURE_DIRECTIONS.md` as a separate file (Phase A already produced
  future directions — they are provided below for inclusion in PACKAGE.json)

The math is already proved. Treat the Lean files below as the
ground truth — your prose should explain and contextualize them.
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: These directions extend the `ordEGF` bridge in
**Domain**: Logic
**Mathematical framing**: # Future Directions

These directions extend the `ordEGF` bridge in
`Catalog/Bridges/SpeciesTropicalValuation.lean` from a single order-only invariant toward
richer tropical and valuation-theoretic semantics for combinatorial sequences.

## 1. From order-only profiles to coefficientwise valuation profiles

The current invariant `ordEGF a = order (egf a)` retains only the *first* place where the EGF
is supported; it discards everything about the remaining coefficients. The key insight is that
the order map is just the degree-`0` shadow of a far finer object — the full *valuation profile*
`n ↦ v(coeff n (egf a))` valued in an ordered value group — and the same two transport lemmas
(`order_mul`, `min_order_le_order_add`) are the leading-term specializations of coefficientwise
additivity and ultrametric subadditivity. Why now? Because the bridge already isolates the exact
two power-series facts being transported, so swapping `order` for a `p`-adic or `X`-adic
valuation profile is a localized change: once Mathlib's valuation infrastructure on
`PowerSeries`/Laurent series is connected to `egf`, the present theorems generalize almost
verbatim to a coefficientwise profile that detects cancellation in *every* degree rather than
only the first.

## 2. A genuine tropical-semiring homomorphism object

Right now the multiplicative and additive bridges live as two separate theorems. The key
insight is that `ordEGF` is a structure-preserving map from the exponential-convolution
semiring `(ℕ → ℚ, binConv, +)` into the tropical semiring `(WithTop ℕ, +, min)`, and that this
should be packaged as a bundled semiring (or at least monoid) homomorphism rather than as loose
lemmas. Why now? Because `Catalog/Applications/SpeciesConvolutionRing.lean` already exhibits the
counting sequences as a commutative semiring under `binConv`, so the domain object exists; the
only missing piece is choosing the right tropical target instance, after which `ordEGF_binConv`
and `ordEGF_add_ge` become the `map_mul`/`map_add`-style fields of a single bundled morphism that
downstream files can apply uniformly.

## 3. Sharp cancellation criteria for the additive bridge

The additive bridge is an inequality, `min (ordEGF a) (ordEGF b) ≤ ordEGF (a + b)`, and the gap
is exactly leading-term cancellation. The key insight is that equality fails *iff* the lowest
nonvanishing coefficients of `egf a` and `egf b` sit in the same degree and cancel, which is a
decidable, fully explicit condition on `a` and `b` at the common order. Why now? Because the
order API in Mathlib (`order_le`, `coeff_order`, and friends) already exposes the leading
coefficient, so a clean `ordEGF (a + b) = min (ordEGF a) (ordEGF b)` theorem under a
"no leading cancellation" hypothesis is within immediate reach and would turn the present
superadditivity into a tight tropical valuation law.

## 4. Tropicalized species operations and a Newton-polygon layer

The species corollary layer is currently a thin wrapper (`speciesOrdEGF`, with `setSpecies` as a
worked example). The key insight is that order is the first vertex of the Newton polygon of the
EGF, so attaching the *whole lower convex hull* of `(n, v(aₙ))` to a species would upgrade
`speciesOrdEGF` from a single number to a piecewise-linear tropical curve that is additive under
species product (Newton polygons add via Minkowski sum). Why now? Because the project's species
infrastructure already supplies the counting sequence and its EGF for concrete species (sets,
linear orders, derivative, pointing), giving a ready supply of test cases on which a
Newton-polygon invariant can be defined and validated before any heavy general theory is built.

## 5. Transfer to ordinary generating functions and other transforms

The bridge is currently tied to the *exponential* transform `egf`. The key insight is that the
order valuation is transform-agnostic: any coefficient-preserving-up-to-units transform (the
ordinary generating function, the Borel transform, Hadamard products) induces its own order
bridge, and the divisor `n!` in `egf` is a unit in `ℚ` precisely so that `ordEGF` coincides with
the raw support order of `a`. Why now? Because the proofs here factor cleanly through `egf_mul`
and `egf_add` rather than through the specific shape of `egf`, so re-deriving the same package for
an OGF transform (with the appropriate convolution `Finset.antidiagonal` instead of `binConv`)
is a parallel, low-risk development that would let later work compare valuation profiles across
transforms within one uniform tropical framework.

Research domain: Logic
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Logic/FibonacciPrimitiveDivisorBounded.lean
import Mathlib

/-! # Carmichael's Fibonacci Primitive Divisor Theorem — the unconditionally proved range

A *primitive prime divisor* of the Fibonacci number `F(n)` is a prime `p` with
`p ∣ F(n)` but `p ∤ F(k)` for every `0 < k < n`. Carmichael's 1913 theorem states
that `F(n)` has a primitive prime divisor for every `n ∉ {1, 2, 6, 12}`.

This file gives a **fully verified, `sorry`-free** proof of Carmichael's theorem on
the range `13 ≤ n ≤ 10000`. It is self-contained (depends only on Mathlib) and is
built from two independent pillars:

* **Prime indices** (`fib_primitive_divisor_prime`): a *clean, unconditional* proof
  that for every prime `n ≥ 3`, **every** prime factor of `F(n)` is primitive. This
  is an entry-point argument: a prime `q ∣ F(n)` has its Fibonacci entry point
  dividing `n`; for prime `n` that entry point is `1` or `n`, and `1` is impossible
  since `F(1) = 1`.

* **Composite indices** (`primPart_implies_primitive` + `primPart_check`): a verified
  GCD "strip the imprimitive part" algorithm `primPart`, whose positivity certifies a
  primitive divisor, checked over `13 ≤ n ≤ 10000` by `native_decide`.

The unbounded composite tail (`n > 10000`) is the genuinely deep part of Carmichael's
theorem (Lifting-the-Exponent for Fibonacci) and is deliberately **not** asserted here;
see `FUTURE_DIRECTIONS.md`.

-- !-- Lab Notes -- !--
-- HYPOTHESIS: The two regimes (prime index vs composite index) require genuinely
--   different proofs. Prime indices admit a short structural proof; composite indices
--   need a computational certificate because the imprimitive factors are irregular.
-- EXPERIMENT 1: Tried to unify both cases through `primPart` only. FAILURE — `primPart`
--   for a prime index strips nothing (only proper divisor is 1, F(1)=1), so the
--   certificate `1 < primPart n` is true but the strip-loop reasoning is heavier than
--   the direct entry-point argument. INSIGHT: keep the prime case separate and short.
-- EXPERIMENT 2: Confirmed the entry-point bound: for prime n, gcd(n,k) for 0<k<n is a
--   proper divisor of a prime, hence 1; this collapses the primitivity check to F(1)=1.
--   SUCCESS — this is the core of `fib_primitive_divisor_prime`.
-- EXPERIMENT 3: `native_decide` on `primPart_check` over [13,10000] is feasible; the
--   GCD strip loop is fast. Larger ranges blow up compile time, motivating the
--   asymptotic LTE approach recorded in FUTURE_DIRECTIONS.md.
-/

set_option maxHeartbeats 800000

namespace FibPrimitiveBounded

/-! ## Basic Fibonacci facts -/

/-- `F(n) > 1` for `n ≥ 3`. -/
lemma fib_gt_one (n : ℕ) (hn : 3 ≤ n) : 1 < Nat.fib n := by
  match n, hn with
  | 3, _ => decide
  | n + 4, _ =>
    have := @Nat.fib_add_two (n + 2)
    have := Nat.fib_pos.mpr (show 0 < n + 3 by omega)
    have := Nat.fib_pos.mpr (show 0 < n + 2 by omega)
    linarith

/-- Strong divisibility: if `p ∣ F(n)` and `p ∣ F(k)`, then `p ∣ F(gcd n k)`. -/
lemma fib_dvd_gcd_of_dvd (p n k : ℕ) (hpn : p ∣ Nat.fib n) (hpk : p ∣ Nat.fib k) :
    p ∣ Nat.fib (Nat.gcd n k) := by
  rw [Nat.fib_gcd]; exact Nat.dvd_gcd hpn hpk

/-! ## The prime-index case (unconditional)

For a prime index `n`, every prime factor of `F(n)` is primitive. -/

/-- **Prime-index Carmichael.** For prime `n ≥ 3`, the least prime factor of `F(n)`
    (indeed every prime factor) is a primitive prime divisor of `F(n)`. -/
theorem fib_primitive_divisor_prime (n : ℕ) (hn : 3 ≤ n) (hnp : Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  have hfn : 1 < Nat.fib n := fib_gt_one n hn
  refine ⟨Nat.minFac (Nat.fib n), Nat.minFac_prime (by omega), Nat.minFac_dvd _, ?_⟩
  intro k hk hkn hqk
  -- The minimal prime factor `q` of `F(n)` divides `F(gcd n k)`.
  have hg : Nat.minFac (Nat.fib n) ∣ Nat.fib (Nat.gcd n k) :=
    fib_dvd_gcd_of_dvd _ n k (Nat.minFac_dvd _) hqk
  -- `gcd n k` is a positive divisor of the prime `n`, strictly below `n`, hence `= 1`.
  have hdvd : Nat.gcd n k ∣ n := Nat.gcd_dvd_left _ _
  have hlt : Nat.gcd n k < n := lt_of_le_of_lt (Nat.gcd_le_right n hk) hkn
  have hone : Nat.gcd n k = 1 := by
    rcases (Nat.Prime.eq_one_or_self_of_dvd hnp _ hdvd) with h | h
    · exact h
    · omega
  rw [hone, Nat.fib_one] at hg
  exact (Nat.minFac_prime (by omega)).not_dvd_one hg

/-! ## The composite-index case (computational certificate)

We strip, from `F(n)`, all prime factors shared with `F(d)` for proper divisors
`d ∣ n`. If the residue exceeds `1` it provides a primitive prime divisor. -/

/-- Strip all factors of `m` from `r`, with bounded fuel. -/
def stripAllAux (r : ℕ) (m : ℕ) : ℕ → ℕ
  | 0 => r
  | fuel + 1 =>
    if m ≤ 1 then r
    else
      let g := Nat.gcd r m
      if g ≤ 1 then r
      else stripAllAux (r / g) m fuel

/-- Proper divisors of `n` (`d` with `0 < d < n` and `d ∣ n`). -/
def propDivs (n : ℕ) : List ℕ :=
  (List.range n).filter fun d => 0 < d && d < n && n % d == 0

/-- The primitive part of `F(n)`: strip out every prime shared with a proper-divisor
    Fibonacci number. -/
def primPart (n : ℕ) : ℕ :=
  let fn := Nat.fib n
  (propDivs n).foldl (fun r d => stripAllAux r (Nat.fib d) r) fn

lemma stripAllAux_dvd (r m fuel : ℕ) : stripAllAux r m fuel ∣ r := by
  induction fuel generalizing r with
  | zero => exact dvd_refl r
  | succ fuel ih =>
    simp only [stripAllAux]
    split_ifs with h1 h2
    · exact dvd_refl r
    · exact dvd_refl r
    · exact dvd_trans (ih (r / Nat.gcd r m)) (Nat.div_dvd_of_dvd (Nat.gcd_dvd_left r m))

lemma stripAllAux_coprime (r m fuel : ℕ) (hm : 1 < m) (hr : 0 < r) (hfuel : r ≤ fuel) :
    Nat.gcd (stripAllAux r m fuel) m = 1 := by
  induction' fuel with fuel ih generalizing r m
  · grind +qlia
  · by_cases hgr : Nat.gcd r m > 1
    · convert ih (r / Nat.gcd r m) m hm
        (Nat.div_pos (Nat.le_of_dvd hr (Nat.gcd_dvd_left _ _)) hgr.le) _ using 1
      · grind +locals
      · exact Nat.le_of_lt_succ (Nat.div_lt_of_lt_mul <| by
          nlinarith [Nat.div_mul_cancel (Nat.gcd_dvd_left r m)])
    · interval_cases _ : Nat.gcd r m <;> simp_all +decide [stripAllAux]

lemma primPart_dvd (n : ℕ) : primPart n ∣ Nat.fib n := by
  simp only [primPart]
  induction' (propDivs n) using List.reverseRecOn with d l ih <;> simp_all +decide [List.foldl]
  exact dvd_trans (stripAllAux_dvd _ _ _) ih

lemma primPart_coprime_proper_divs (n : ℕ) (hpp : 1 < primPart n) (d : ℕ)
    (hd : d ∈ propDivs n) : ¬((primPart n).minFac ∣ Nat.fib d) := by
  have h_coprime : Nat.gcd (primPart n) (Nat.fib d) = 1 := by
    have h_coprime : ∀ l : List ℕ, d ∈ l →
        Nat.gcd (List.foldl (fun r d => stripAllAux r (Nat.fib d) r) (Nat.fib n) l)
          (Nat.fib d) = 1 := by
      intros l hl
      induction' l using List.reverseRecOn with l ih <;> simp_all +decide [Nat.gcd_comm]
      by_cases h : Nat.fib ih > 1 <;>
        by_cases h' : 0 < List.foldl (fun r d => stripAllAux r (Nat.fib d) r) (Nat.fib n) l <;>
        simp_all +decide
      · have := stripAllAux_coprime
          (List.foldl (fun r d => stripAllAux r (Nat.fib d) r) (Nat.fib n) l)
          (Nat.fib ih)
          (List.foldl (fun r d => stripAllAux r (Nat.fib d) r) (Nat.fib n) l) h h'
          (by linarith)
        simp_all +decide [Nat.gcd_comm]
        cases hl <;> simp_all +decide
        exact Nat.Coprime.coprime_dvd_right (stripAllAux_dvd _ _ _) ‹_›
      · have h_contra : ∀ l : List ℕ,
            List.foldl (fun r d => stripAllAux r (Nat.fib d) r) (Nat.fib n) l = 0 → False := by
          intros l hl
          induction' l using List.reverseRecOn with l ih <;> simp_all +decide
          have := stripAllAux_dvd
            (List.foldl (fun r d => stripAllAux r (Nat.fib d) r) (Nat.fib n) l)
            (Nat.fib ih)
            (List.foldl (fun r d => stripAllAux r (Nat.fib d) r) (Nat.fib n) l)
          simp_all +decide
        exact False.elim <| h_contra l h'
      · rcases ih with (_ | _ | ih) <;> simp_all +arith +decide [Nat.fib_add_two]
        · cases hl <;> 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# FUTURE DIRECTIONS — Fibonacci Primitive Divisors / Carmichael's Theorem

This cycle delivered `Catalog/Logic/FibonacciPrimitiveDivisorBounded.lean`, a
self-contained, `sorry`-free verification of Carmichael's primitive-divisor
theorem on the range `13 ≤ n ≤ 10000`, together with:

* `fib_primitive_divisor_prime` — an *unconditional* proof for all prime indices
  `n ≥ 3` (every prime factor of `F(n)` is primitive);
* `fib_gcd_identity` — the strong-divisibility identity underpinning the theory;
* `fib_exceptional_no_primitive` — sharpness: `F(n)` has no primitive prime
  divisor for `n ∈ {1, 2, 6, 12}`, so `13` is the sharp threshold.

The genuinely open formalization target is the **unbounded composite tail**.
The conjectures below are stated so they can be transcribed almost verbatim into
Lean statements and attacked in follow-up cycles.

---

## Conjecture 1 (PRIORITY): Fibonacci Lifting-the-Exponent

For an odd prime `p` whose Fibonacci entry point is `z(p) = m` (i.e. `m` is least
with `p ∣ F(m)`), and any `k ≥ 1`:

```
padicValNat p (Nat.fib (m * k)) = padicValNat p (Nat.fib m) + padicValNat p k.
```

**Why it matters.** This is the single missing analytic ingredient for the
unbounded tail. It controls exactly how much of `F(n)` is "imprimitive", and
combined with `F(n) ≥ φ^{n-2}` it forces a primitive factor for large `n`.

**Falsifiable test.** Check numerically for `p ∈ {3,7,11,...}`, `k ≤ 20`; a single
counterexample refutes it. (None expected — this is classical, but unformalized.)

---

## Conjecture 2: Primitive part dominates the index

Define the Möbius-cyclotomic primitive part
`Φ(n) = ∏_{d ∣ n} F(d) ^ μ(n/d)` (a positive integer). Then for every
`n ≥ 13`:

```
Φ(n) > n.
```

**Why it matters.** `Φ(n) > 1` already implies a primitive prime divisor; the
strict bound `Φ(n) > n` is the clean inequality that removes the `native_decide`
range cap entirely and yields the full theorem for ALL `n ≥ 13` (prime or
composite) in one stroke.

**Falsifiable test.** `Φ(12) = 144 / (F(6)·F(4)·F(2)... )` collapses to a
non-dominant value — verify the bound first fails exactly inside `{1,2,6,12}`.

---

## Conjecture 3: Entry point divides `p − (5|p)`

For a prime `p ≠ 5`, the Fibonacci entry point `z(p)` satisfies

```
z(p) ∣ (p - legendreSym p 5),   i.e. z(p) ∣ p - 1  or  z(p) ∣ p + 1,
```

according to whether `5` is a quadratic residue mod `p`.

**Why it matters.** This gives an *a priori* upper bound `z(p) ≤ p + 1`, the key
to proving that an imprimitive prime `p ∣ F(n)` must satisfy `p ∣ n` with
multiplicity one — the combinatorial half of the tail argument.

**Falsifiable test.** Tabulate `z(p)` vs `p ± 1` for primes `p < 200`.

---

## Conjecture 4: Lucas-number analogue

The Lucas numbers `L(n)` (`L 0 = 2`, `L 1 = 1`, `L(n+2) = L(n+1)+L(n)`) have a
primitive prime divisor for every `n ∉ {1, 6}`.

**Why it matters.** Lucas and Fibonacci sequences share companion-matrix
eigenvalues; a uniform "Lucas-sequence primitive divisor" lemma would l
```

## Your task

Produce the deliverables listed above. The Lean file is the source of truth —
your prose must accurately explain it. Both ARTICLE.md and RESEARCH_PAPER.md
MUST be self-contained and publishable without referencing any external files.
State every theorem, definition, and result inline so a reader can follow the
entire argument from the document alone.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a clear, professional mathematical title in 'name' (do not use generic placeholders; this will be displayed as the header on the interactive site), a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. For each Python demo in the demos array, provide a highly descriptive title in 'name', a comprehensive functional description in 'description', and the implementation code in 'code'. For each interactive HTML demo in interactive_demos, provide a beautiful title in 'title' and a detailed description in 'description'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
