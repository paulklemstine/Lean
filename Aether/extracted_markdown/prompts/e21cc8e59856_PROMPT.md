Soli Deo Gloria

## Assignment: Direction 5 — Automorphic Forms on `GL_2(𝔸_ℚ)`

**Mode:** `prove`

## Mission

Formalize and prove a genuinely structural adelic–classical correspondence for the spherical sector of automorphic forms on `GL_2(𝔸_ℚ)`, using the restricted product / cylinder-measure infrastructure from the catalog as the analytic backbone. Do not settle for a dictionary of definitions: extract the first mathematically meaningful, machine-verified bridge between adelic harmonic analysis and classical modular-form data.

The core breakthrough is to isolate a Lean-formalizable theorem schema that captures the **spherical Hecke action** adelically and identifies it with the **classical Hecke recursion** on Fourier coefficients. Even if the full Langlands correspondence is beyond one cycle, a verified theorem that the unramified adelic Hecke algebra acts through the same local eigenvalue data as the classical modular side would be a field-opening foundation.

Build explicitly on:

- `Pythagorean/HaarRestrictedProduct/Defs.lean`
- `Pythagorean/HaarRestrictedProduct/Theorems.lean`

Use them not just as background, but as the engine for constructing restricted products, cylinder sets/functions, and product-compatible integration.

---

## Precise Research Target

Your starting conjecture is correct in spirit but too broad to formalize all at once. Refine it into a sequence of exact theorems that isolate the **unramified local-to-global mechanism**.

### New formal objects you should define

You must introduce at least one genuinely new concept absent from the catalog. Recommended definitions:

1. **Spherical test function at a prime**
   - the characteristic cylinder function of the double coset
     `GL_2(ℤ_p) * diag(p,1) * GL_2(ℤ_p)`
   - viewed inside a restricted-product Hecke algebra model.

2. **Unramified Hecke eigenpacket**
   - a structure encoding a sequence `a : ℕ → R` satisfying the classical Hecke recursion
     and local Satake-type relations.

3. **Adelic Fourier–Hecke compatibility**
   - a predicate asserting that an adelic function and a coefficient sequence are compatible
     under the local Hecke action.

A plausible Lean skeleton:

```lean
structure UnramifiedHeckePacket (R : Type _) [CommSemiring R] where
  a : ℕ → R
  a_one : a 1 = 1
  hecke_rec :
    ∀ m n : ℕ, Nat.Coprime m n → a (m * n) = a m * a n
  prime_power_rec :
    ∀ (p r : ℕ), Nat.Prime p →
      a (p^(r+2)) = a p * a (p^(r+1)) - (p : R) * a (p^r)
```

If subtraction is awkward over a semiring, work over a commutative ring or field:

```lean
structure UnramifiedHeckePacket (R : Type _) [CommRing R] where
  a : ℕ → R
  a_one : a 1 = 1
  hecke_mul :
    ∀ m n : ℕ, Nat.Coprime m n → a (m * n) = a m * a n
  prime_power_rec :
    ∀ (p r : ℕ), Nat.Prime p →
      a (p^(r+2)) = a p * a (p^(r+1)) - (p : R) * a (p^r)
```

This is not yet “all automorphic forms”; it is the exact algebraic shadow of the spherical unramified spectrum, and proving that adelic Hecke operators force this recursion is already a serious theorem.

---

## Exact theorem statements to target

You must prove at least 3 nontrivial theorems. Here is the recommended theorem suite.

### Theorem 1: Double-coset multiplicativity induces coprime Hecke multiplicativity

**Mathematical statement.**  
Let `a : ℕ → R` be the coefficient system attached to a spherical adelic eigenfunction for the restricted-product Hecke algebra of `GL_2`. If the local Hecke action factors through convolution of spherical double cosets and the eigenfunction is normalized by `a 1 = 1`, then for coprime `m,n`,
\[
a(mn)=a(m)a(n).
\]

This is the first global structural theorem: the adelic restricted-product factorization implies Euler multiplicativity.

**Lean-style signature target:**
```lean
theorem coeff_mul_of_coprime
    {R : Type _} [CommRing R]
    (pkt : UnramifiedHeckePacket R) :
    ∀ {m n : ℕ}, Nat.Coprime m n →
      pkt.a (m * n) = pkt.a m * pkt.a n
```

If you instead derive this theorem from a more primitive adelic object, even better:

```lean
theorem spherical_eigencoeff_mul_of_coprime
    {R : Type _} [CommRing R]
    (F : SphericalAdelicForm R)
    (hF : IsHeckeEigenform F) :
    ∀ {m n : ℕ}, Nat.Coprime m n →
      heckeCoeff F (m * n) = heckeCoeff F m * heckeCoeff F n
```

**Why this matters.**  
This theorem turns restricted-product harmonic analysis into an Euler product mechanism. It is the formal seed of automorphic `L`-functions.

---

### Theorem 2: Prime-power Hecke recursion from the spherical local Hecke algebra

**Mathematical statement.**  
For every prime `p`, the eigenvalues attached to the spherical double-coset operators satisfy the classical recursion
\[
a(p^{r+2}) = a(p)\,a(p^{r+1}) - p\,a(p^r),
\]
or a weight-adjusted variant if your normalization includes modular weight. If you need to work with a parameter `χ(p)` or a central character, state the generalized version precisely.

**Lean-style signature target:**
```lean
theorem coeff_prime_power_rec
    {R : Type _} [CommRing R]
    (pkt : UnramifiedHeckePacket R) :
    ∀ {p r : ℕ}, Nat.Prime p →
      pkt.a (p^(r+2)) = pkt.a p * pkt.a (p^(r+1)) - (p : R) * pkt.a (p^r)
```

Or in weighted normalization:
```lean
theorem coeff_prime_power_rec_weight_k
    {R : Type _} [CommRing R]
    (k : ℕ)
    (pkt : WeightedHeckePacket R k) :
    ∀ {p r : ℕ}, Nat.Prime p →
      pkt.a (p^(r+2)) =
        pkt.a p * pkt.a (p^(r+1)) - (p : R)^(k-1) * pkt.a (p^r)
```

**Why this matters.**  
This is the local Satake shadow in concrete recursive form. A machine-verified proof of this identity from an adelic convolution model is far more important than another isolated modular arithmetic lemma.

---

### Theorem 3: Hecke relation for general indices via divisor convolution

**Mathematical statement.**  
For normalized spherical eigenpackets, prove the full Hecke relation
\[
a(m)a(n)=\sum_{d \mid \gcd(m,n)} d \, a\!\left(\frac{mn}{d^2}\right)
\]
or the weight-adjusted version
\[
a(m)a(n)=\sum_{d \mid \gcd(m,n)} d^{k-1} a\!\left(\frac{mn}{d^2}\right).
\]

This theorem is the strongest arithmetic footprint of the spherical Hecke algebra that is realistically formalizable now.

**Lean-style signature target:**
```lean
theorem coeff_hecke_relation
    {R : Type _} [CommRing R]
    (pkt : UnramifiedHeckePacket R) :
    ∀ m n : ℕ,
      pkt.a m * pkt.a n =
        ∑ d in Nat.divisors (Nat.gcd m n),
          (d : R) * pkt.a (m * n / (d * d))
```

If divisibility side conditions make this awkward, package the summand with a proof that `d*d ∣ m*n` whenever `d ∣ gcd(m,n)`.

**Why this matters.**  
This is the finite-level shadow of the full Hecke algebra multiplication law. Once formalized, it becomes the arithmetic API for future work on Euler products, Rankin–Selberg convolutions, and explicit Langlands correspondences.

---

### Theorem 4: Cross-domain theorem — generating series satisfies a rational local functional equation

You are required to include a cross-domain bridge. The strongest accessible one here is:

**Number theory ↔ formal power series / dynamical systems / spectral theory**

For each prime `p`, define the local generating function
\[
G_p(T)=\sum_{r\ge 0} a(p^r)T^r.
\]
Prove from the prime-power recursion that
\[
(1-a(p)T+pT^2)\,G_p(T)=1
\]
(or with `p^(k-1)` in weight `k` normalization).

**Lean-style signature target:**
```lean
theorem local_euler_factor_identity
    {R : Type _} [CommRing R]
    (pkt : UnramifiedHeckePacket R)
    {p : ℕ} (hp : Nat.Prime p) :
    let G : FormalPowerSeries R := ∑' r : ℕ, FormalPowerSeries.monomial r (pkt.a (p^r))
    in
    (1 - FormalPowerSeries.C (pkt.a p) * FormalPowerSeries.X
       + FormalPowerSeries.C (p : R) * FormalPowerSeries.X^2) * G = 1
```

If `FormalPowerSeries` summation is too heavy, prove the coefficientwise version:
```lean
theorem local_euler_factor_coeffwise
    {R : Type _} [CommRing R]
    (pkt : UnramifiedHeckePacket R)
    {p n : ℕ} (hp : Nat.Prime p) :
    coeff ℕ n
      ((1 - C (pkt.a p) * X + C (p : R) * X^2) * localSeries pkt p)
      = if n = 0 then 1 else 0
```

**Why this is revolutionary.**  
This converts automorphic data into a transfer-function identity. That is a real bridge to signal processing, dynamical systems, and spectral methods: unramified local factors become rational response functions. This is the kind of unexpected cross-pollination that opens new formal mathematics.

---

## Most promising proof architectures

You asked for 2–3 proof strategy steps. Here are three viable routes; pursue at least two in the file comments or paper.

### Strategy A: Arithmetic-first formalization via Hecke packet axioms
**Best for guaranteed progress.**

1. Define `UnramifiedHeckePacket` as the distilled algebraic content of spherical adelic eigenforms.
2. Prove the full Hecke relation from:
   - coprime multiplicativity,
   - prime-power recursion,
   - induction on valuations / factorization into prime powers.
3. Derive the local Euler factor identity coefficientwise by a `calc` proof using the recursion.

**Why promising:**  
This route avoids formalizing all analytic details of automorphic forms immediately while still capturing the theoremically essential content. It creates a reusable abstraction layer for later adelic realization theorems.

---

### Strategy B: Restricted-product convolution route from catalog cylinder measures
**Most visionary; use if the catalog infrastructure is strong enough.**

1. Define local spherical double-coset cylinder functions in the restricted product using the catalog’s Haar/cylinder measure constructions.
2. Show convolution of these cylinder functions matches the standard Hecke multiplication law at unramified places.
3. Push eigenfunction evaluation through the convolution identities to obtain multiplicativity and prime-power recursion.

**Why promising:**  
This is the true adelic heart of the project. If successful, it gives a machine-verified local Hecke algebra inside a restricted-product measure framework — a major formal harmonic analysis advance.

---

### Strategy C: Generating-function / recurrence route
**Best for the cross-domain theorem.**

1. Start from the prime-power recursion.
2. Multiply the local generating series by the quadratic Euler polynomial.
3. Prove coefficientwise cancellation for all positive coefficients by induction on `n`, using `field_simp` or ring manipulations where needed.

**Why promising:**  
This yields deep theorems with manageable Lean complexity and creates a conceptual bridge to spectral and control-theoretic language.

---

## Recommended theorem dependency graph

A strong file architecture would be:

1. `def UnramifiedHeckePacket ...`
2. Basic lemmas on divisibility, gcd, prime powers
3. `theorem coeff_mul_of_coprime`
4. `theorem coeff_prime_power_rec`
5. Prime-power closed lemmas by induction
6. `theorem coeff_hecke_relation`
7. `def localSeries ...`
8. `theorem local_euler_factor_identity`
9. Optional realization theorem connecting a packet to an adelic spherical eigenfunction

This ensures at least 3 nontrivial proofs using induction, `rcases`, `by_contra`, `field_simp`, and long `calc` chains.

---

## Lean 4 formalization notes

You should aim for signatures close to the following.

```lean
structure UnramifiedHeckePacket (R : Type _) [CommRing R] where
  a : ℕ → R
  a_one : a 1 = 1
  hecke_mul :
    ∀ m n : ℕ, Nat.Coprime m n → a (m * n) = a m * a n
  prime_power_rec :
    ∀ (p r : ℕ), Nat.Prime p →
      a (p^(r+2)) = a p * a (p^(r+1)) - (p : R) * a (p^r)
```

```lean
theorem coeff_mul_of_coprime
    {R : Type _} [CommRing R]
    (pkt : UnramifiedHeckePacket R)
    {m n : ℕ} (h : Nat.Coprime m n) :
    pkt.a (m * n) = pkt.a m * pkt.a n
```

```lean
theorem coeff_prime_power_rec
    {R : Type _} [CommRing R]
    (pkt : UnramifiedHeckePacket R)
    {p r : ℕ} (hp : Nat.Prime p) :
    pkt.a (p^(r+2)) = pkt.a p * pkt.a (p^(r+1)) - (p : R) * pkt.a (p^r)
```

```lean
theorem coeff_hecke_relation
    {R : Type _} [CommRing R]
    (pkt : UnramifiedHeckePacket R)
    (m n : ℕ) :
    pkt.a m * pkt.a n =
      ∑ d in Nat.divisors (Nat.gcd m n),
        (d : R) * pkt.a (m * n / (d * d))
```

```lean
def localSeries
    {R : Type _} [CommRing R]
    (pkt : UnramifiedHeckePacket R) (p : ℕ) : FormalPowerSeries R := ...
```

```lean
theorem local_euler_factor_identity
    {R : Type _} [CommRing R]
    (pkt : UnramifiedHeckePacket R)
    {p : ℕ} (hp : Nat.Prime p) :
    (1 - FormalPowerSeries.C (pkt.a p) * FormalPowerSeries.X
       + FormalPowerSeries.C (p : R) * FormalPowerSeries.X^2)
      * localSeries pkt p = 1
```

If the full divisor-sum theorem is too large, prove a prime-power version first:
```lean
theorem coeff_hecke_relation_prime_powers
    {R : Type _} [CommRing R]
    (pkt : UnramifiedHeckePacket R)
    {p a b : ℕ} (hp : Nat.Prime p) :
    pkt.a (p^a) * pkt.a (p^b) =
      ∑ i in Finset.range (Nat.min a b + 1),
        ((p : ℕ)^i : R) * pkt.a (p^(a + b - 2*i))
```
Then derive the general theorem by multiplicativity across primes.

---

## Cross-domain connections to emphasize

You are required to connect domains. Do it explicitly.

1. **Number theory ↔ harmonic analysis**  
   The spherical Hecke algebra is a convolution algebra of bi-`K`-invariant functions on local groups.

2. **Number theory ↔ formal power series / dynamical systems**  
   Local Euler factors are transfer functions of second-order recurrences.

3. **Representation theory ↔ signal processing**  
   Hecke eigenvalues define linear recurrence filters; Satake parameters are poles/eigenmodes.

4. **Automorphic forms ↔ statistical mechanics**  
   Euler products can be interpreted as partition functions of independent local modes.

5. **Automorphic forms ↔ computation**  
   The recursion gives an efficient algorithm for generating prime-power coefficients and testing consistency of purported eigenpackets.

These are not decorative. They should shape the statements in `RESEARCH_PAPER.md` and `ARTICLE.md`.

---

## Computational / algorithmic deliverable

You must provide a verified computational method, not just theorem statements.

### Required algorithm
Implement an algorithm that, given:
- a finite list of primes `p ≤ B`,
- values `a(p)` for those primes,
- a bound `N`,

computes all `a(n)` for `n ≤ N` using:
- prime-power recursion,
- coprime multiplicativity,
- factorization of `n`.

Then prove a correctness theorem:

```lean
theorem compute_coeff_correct
    {R : Type _} [CommRing R]
    (pkt : UnramifiedHeckePacket R)
    (N : ℕ) :
    ∀ n ≤ N, computeCoeff pkt N n = pkt.a n
```

If full factorization correctness is too large, verify correctness for:
- prime powers,
- squarefree numbers,
- multiplicative assembly from factorization data.

This algorithm is mathematically meaningful: it is the first certified Hecke-eigenvalue propagator from local data.

---

## Concrete falsifiable conjecture

You must include at least one falsifiable conjecture with a clear computational disproof criterion.

### Recommended conjecture
For any normalized unramified Hecke packet `pkt : UnramifiedHeckePacket ℤ` satisfying the classical Ramanujan bound at primes up to `B`,
\[
|a(p)| \le 2\sqrt{p} \quad \text{for all primes } p \le B,
\]
the recursively generated coefficients satisfy the local Euler-factor nonvanishing condition for all `p ≤ B` and all complex `|T| < p^{-1/2}`.

**Computational test:**  
For a candidate packet (e.g. Ramanujan tau normalized appropriately), compute the truncated local polynomial and numerically search for zeros inside the forbidden disk. Any zero found there falsifies the conjectured normalization or implementation.

A more arithmetic version:

### Alternate conjecture
If two normalized unramified packets over `ℤ` agree on `a(p)` for all primes `p ≤ B`, then they agree on all `a(n)` for `n ≤ B`.

**Test:**  
Generate coefficients from the recursion and compare. Any mismatch falsifies the deterministic local-to-global propagation claim.

This is weaker than strong multiplicity one, but genuinely testable and formalization-friendly.

---

## Delta / Ramanujan test case

Use the discriminant form `Δ` as the canonical experiment, but phrase carefully: Lean need not yet formalize all of `Δ` analytically. You can still implement the computational dictionary layer.

### Required demo target
For the first 100 primes `p`:
1. obtain classical values `τ(p)` from a trusted explicit source or hard-coded list,
2. feed them as local data into the Hecke-packet algorithm,
3. generate `τ(n)` for composite `n` via the formal recursion,
4. verify the standard Hecke identities numerically.

If you can formalize even a small certified subset of these identities in Lean, that is excellent. The point is to demonstrate that the adelic-style packet formalism reproduces classical Hecke arithmetic.

---

## Why this would be a breakthrough

A successful result here does **not** merely restate textbook modular forms. It creates:

- a certified interface between restricted-product harmonic analysis and arithmetic coefficient systems;
- a formal local Hecke algebra usable in future Langlands formalization;
- a verified algorithm for propagating automorphic data from local eigenvalues;
- a bridge from automorphic forms to recurrence theory, spectral transfer functions, and computational experimentation.

This opens the door to:
- formal Euler products and `L`-functions,
- Rankin–Selberg convolution in Lean,
- explicit spherical representation theory,
- eventually, a formal statement of strong multiplicity one and pieces of the global Langlands correspondence.

This is the kind of infrastructure that changes what formal number theory can even ask.

---

## Mandatory deliverables

You must produce **all** of the following:

1. **A structured `FUTURE_DIRECTIONS.md`**
   - include 3–5 testable scientific hypotheses,
   - each must be falsifiable,
   - each must have a concrete computational or formal test.

2. **A standalone `RESEARCH_PAPER.md`**
   - readable without code access,
   - state the exact theorems proved,
   - explain why the adelic–classical bridge matters,
   - include the algorithmic consequences and next questions.

3. **An accessible `ARTICLE.md`**
   - Scientific American style,
   - explain what adeles are, why local-to-global matters,
   - show how symmetries at each prime combine into global arithmetic structure.

4. **A verified algorithm or computational method**
   - the Hecke coefficient propagation algorithm is the minimum acceptable target.

5. **A `demo.py`**
   - interactively compute coefficients from local prime data,
   - test Hecke relations,
   - showcase the `Δ` / Ramanujan example or a simplified packet model.

---

## Application keywords

Automorphic forms; adelic harmonic analysis; spherical Hecke algebra; modular forms; Langlands program; restricted products; Haar measure; cylinder measures; Euler products; formal power series; recurrence relations; spectral theory; transfer functions; arithmetic algorithms; certified computation; Hecke eigenvalues; local-to-global principles.

---

## Final directive

Do not spend the cycle on vague infrastructure. Prove concrete Hecke-structure theorems with real algebraic content. If the full adelic-classical bijection is too ambitious, **carve out the unramified Hecke packet core and prove it completely**. That core is already a publishable conceptual advance if it is genuinely tied back to the restricted-product Haar framework from the catalog.

### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "Lean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  Show the math working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Every research cycle MUST produce a
FUTURE_DIRECTIONS.md that identifies 3-5 specific, testable scientific
hypotheses, including 1-2 grand_challenge paradigm-shifting conjectures
and 2-3 solid extensions building directly on Catalog theorems.
MUST begin with a ## Synthesis section tying all directions together.
Each direction must use the structured format with explicit fields:
**Conjecture**, **Test**, **Impact**, **Catalog References**,
**Proof Strategy**, **Domain Bridges**, **Lineage**, **Ambition**.
Reference specific Catalog theorems by file path. Every hypothesis
must be daring enough to matter and specific enough to fail.


────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — JSON Data Package  →  PACKAGE.json
────────────────────────────────────────────────────────────────────────────
Create a **single JSON file** that bundles ALL artifacts for the web templating system.
Requirements:

• **Structure**: Output a strictly valid JSON object matching this schema:
  {
    "title": "Title of the Research",
    "domain": "Mathematical Domain",
    "article": "Markdown content...",
    "research_paper": "Markdown content...",
    "future_directions": "Markdown content...",
    "demos": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files like 'algorithms'" } ],
    "algorithms": [ { "name": "...", "pseudocode": "...", "code": "executable Python implementation" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Pythagorean
Research mode: prove
