## Assignment: Primality Testing Beyond Certification — Formalizing Randomness, Determinism, and Spectral Witnesses of Primality

**Mode:** `prove`

Prove genuinely new theorems in Lean 4 around primality testing that do more than repackage textbook correctness. The target is a formal bridge between three worlds:

1. **probabilistic primality certification** via Miller–Rabin,
2. **deterministic primality certification** via AKS-style polynomial congruences,
3. **cross-domain witness theory** linking modular arithmetic to spectral/combinatorial collision bounds.

The breakthrough is not “formalize AKS exists.” The breakthrough is to create a **unified witness framework** in which compositeness is detected either by multiplicative dynamics in `(Z/nZ)ˣ`, by truncated polynomial identities in `(Z/nZ)[X]`, or by modular collision/spectral obstructions. This would turn Lean’s number theory library into an engine for **certified complexity-theoretic arithmetic**, not merely a repository of isolated lemmas.

Build on the catalog theorems:

- `miller_rabin_bound` from `Algebra/Core/OpenQuestions.lean`
- `miller_rabin_error_prob_le_quarter` from `Speculative/PrimalityTesting/MillerRabin.lean`
- `spectral_energy_modular_collision_bound` from `FINAL/Algebra/Transfer.lean`
- optionally use `bogoliubov_total_error_bound` as a reusable abstract error-amplification pattern if helpful

Do **not** settle for a wrapper theorem saying the error is ≤ `(1/4)^k`; prove structural theorems about witness sets, amplification, and deterministic certification.

---

## Core New Definitions You Must Introduce

At least one genuinely new concept is mandatory. Prefer introducing all three below.

### 1. Strong liar / witness set as a formal finite set
Define the set of Miller–Rabin strong liars for an odd integer `n`:

```lean
def StrongLiarSet (n : ℕ) : Finset ℕ := ...
```

with membership expressing:
- `1 < a`
- `a < n`
- `Nat.coprime a n`
- writing `n - 1 = 2^s * d` with `d` odd,
- either `a^d ≡ 1 [MOD n]` or `∃ r < s, a^(2^r * d) ≡ -1 [MOD n]`.

This should not merely be a predicate; it should support cardinality arguments.

### 2. AKS congruence witness structure
Define a structure encoding the finite AKS test window:

```lean
structure AKSCertificate (n r amax : ℕ) : Prop where
  ordLarge : ...
  gcdClean : ...
  congruenceWindow :
    ∀ a, 1 ≤ a → a ≤ amax →
      ((Polynomial.X + Polynomial.C (a : ZMod n)) ^ n)
        %ₘ (Polynomial.X ^ r - 1)
      =
      ((Polynomial.X ^ n + Polynomial.C (a : ZMod n)))
        %ₘ (Polynomial.X ^ r - 1)
```

You may need a custom notion of polynomial congruence modulo `X^r - 1`; formalize it cleanly if `%ₘ` is unavailable in the desired form.

### 3. Spectral compositeness profile
Create a new definition connecting arithmetic progressions / residue collisions to compositeness detection:

```lean
def ModularCollisionProfile (n : ℕ) : Type := ...
```

or a predicate

```lean
def HasLowCollisionResidueSystem (n m : ℕ) : Prop := ...
```

designed so that `spectral_energy_modular_collision_bound` can be invoked to show that certain “too-regular” residue systems are impossible for composites with many pseudowitnesses.

This is the cross-domain hinge: arithmetic pseudoprimes should induce combinatorial regularity constraints that are incompatible with spectral bounds.

---

## Precise Theorem Targets

You must prove at least **3 deep theorems**. The following are the preferred targets.

### Theorem 1: Cardinality bound for strong liars
Formalize a structural Miller–Rabin theorem: for odd composite `n`, at most one quarter of admissible bases are strong liars.

A Lean-oriented statement could be:

```lean
theorem strongLiarSet_card_le_quarter
    (n : ℕ)
    (hn_odd : n % 2 = 1)
    (hn_comp : ¬ Nat.Prime n)
    (hn_ge : 3 ≤ n) :
    4 * (StrongLiarSet n).card ≤ n - 1
```

A more precise version, if you define admissible coprime bases separately:

```lean
def MRBaseSet (n : ℕ) : Finset ℕ := ...

theorem strongLiar_density_le_quarter
    (n : ℕ)
    (hn_odd : n % 2 = 1)
    (hn_comp : ¬ Nat.Prime n)
    (hn_ge : 3 ≤ n) :
    4 * (StrongLiarSet n).card ≤ (MRBaseSet n).card
```

**Why this matters:** this upgrades the existing probability bound into a **counting theorem on witness geometry**. That is the real mathematical object behind Miller–Rabin and is what allows later deterministic hitting-set arguments.

Build explicitly on:
- `miller_rabin_bound`
- `miller_rabin_error_prob_le_quarter`

but do not merely restate them; derive a finite-set/cardinality theorem from them.

---

### Theorem 2: Error amplification by independent rounds
Prove a true amplification theorem, phrased as a deterministic inequality over witness densities or as a probabilistic theorem if you define product sampling.

```lean
theorem millerRabin_k_round_error_bound
    (n k : ℕ)
    (hn_odd : n % 2 = 1)
    (hn_comp : ¬ Nat.Prime n)
    (hn_ge : 3 ≤ n) :
    errorProb n k ≤ (1 / 4 : ℚ) ^ k
```

If you avoid probability theory, use finite products:

```lean
theorem liarTupleSet_card_le_pow
    (n k : ℕ)
    (hn_odd : n % 2 = 1)
    (hn_comp : ¬ Nat.Prime n)
    (hn_ge : 3 ≤ n) :
    4^k * (liarTupleSet n k).card ≤ (MRBaseSet n).card ^ k
```

This is a stronger formal object than the scalar probability statement because it can later feed derandomization via explicit hitting sets.

**Why this matters:** once formalized at the tuple/cardinality level, this becomes a reusable abstraction for **probability amplification in finite verification systems**, not just primality testing.

---

### Theorem 3: AKS correctness in certificate form
Do not attempt the full bit-complexity analysis unless the library support is sufficient. Instead, prove a mathematically clean correctness theorem: any `AKSCertificate` certifies primality.

```lean
theorem aks_certificate_correct
    (n r amax : ℕ)
    (hn_gt1 : 1 < n)
    (hcert : AKSCertificate n r amax) :
    Nat.Prime n
```

If full correctness is too library-heavy, prove a strong intermediate theorem:

```lean
theorem aks_congruence_forces_prime
    (n r amax : ℕ)
    (hn_gt1 : 1 < n)
    (hord : sufficientlyLargeOrder n r)
    (hcong : ∀ a, 1 ≤ a → a ≤ amax → PolynomialCongruenceTest n r a)
    (hgcd : gcdSideConditions n r) :
    Nat.Prime n
```

This is already major: it isolates the deep algebraic heart of AKS in a reusable formal theorem.

**Why this matters:** it transforms AKS from “an algorithm known in complexity theory” into a **Lean-certifiable primality certificate schema**.

---

### Theorem 4: Cross-domain theorem — pseudowitness abundance implies spectral obstruction
This is the field-opening theorem. Use the spectral modular collision bound to show that if a composite integer had “too many” pseudowitnesses arranged with too much residue regularity, then one obtains a contradiction with spectral energy estimates.

A candidate theorem:

```lean
theorem many_strong_liars_force_collision_obstruction
    (n m : ℕ)
    (hn_comp : ¬ Nat.Prime n)
    (hprof : HasLowCollisionResidueSystem n m)
    (hliars : m ≤ (StrongLiarSet n).card) :
    False
```

or a softer inequality:

```lean
theorem strongLiar_spectral_upper_bound
    (n : ℕ)
    (hn_comp : ¬ Nat.Prime n)
    (hregular : ResidueRegularityHypothesis n) :
    (StrongLiarSet n).card ≤ spectralBound n
```

using `spectral_energy_modular_collision_bound` as a black-box upper bound on modular collision energy.

**Why this is revolutionary:** it suggests a new research program: **spectral derandomization of primality testing**. Instead of viewing Miller–Rabin and AKS as unrelated, you show that pseudoprime behavior is constrained by additive-combinatorial energy. This opens the door to deterministic primality tests based on collision structure, expander heuristics, or Fourier-analytic residue statistics.

---

## Lean 4 Type Signature Guidance

You asked for precise signatures; here are realistic formalization targets. Adjust namespaces as needed.

```lean
def MRBaseSet (n : ℕ) : Finset ℕ := ...
def StrongLiarSet (n : ℕ) : Finset ℕ := ...
def liarTupleSet (n k : ℕ) : Finset (Fin k → ℕ) := ...

theorem strongLiarSet_card_le_quarter
    (n : ℕ)
    (hn_odd : n % 2 = 1)
    (hn_comp : ¬ Nat.Prime n)
    (hn_ge : 3 ≤ n) :
    4 * (StrongLiarSet n).card ≤ (MRBaseSet n).card := by
  ...

theorem liarTupleSet_card_le_pow
    (n k : ℕ)
    (hn_odd : n % 2 = 1)
    (hn_comp : ¬ Nat.Prime n)
    (hn_ge : 3 ≤ n) :
    4^k * (liarTupleSet n k).card ≤ (MRBaseSet n).card ^ k := by
  ...

structure AKSCertificate (n r amax : ℕ) : Prop where
  ordLarge : Prop
  gcdClean : Prop
  congruenceWindow :
    ∀ a : ℕ, 1 ≤ a → a ≤ amax → Prop

theorem aks_certificate_correct
    (n r amax : ℕ)
    (hn_gt1 : 1 < n)
    (hcert : AKSCertificate n r amax) :
    Nat.Prime n := by
  ...

def HasLowCollisionResidueSystem (n m : ℕ) : Prop := ...

theorem many_strong_liars_force_collision_obstruction
    (n m : ℕ)
    (hn_odd : n % 2 = 1)
    (hn_comp : ¬ Nat.Prime n)
    (hn_ge : 3 ≤ n)
    (hreg : HasLowCollisionResidueSystem n m)
    (hm : m ≤ (StrongLiarSet n).card) :
    False := by
  ...
```

If probability theory is available and manageable, also add:

```lean
def errorProb (n k : ℕ) : ℚ := ...

theorem millerRabin_k_round_error_bound
    (n k : ℕ)
    (hn_odd : n % 2 = 1)
    (hn_comp : ¬ Nat.Prime n)
    (hn_ge : 3 ≤ n) :
    errorProb n k ≤ (1 / 4 : ℚ) ^ k := by
  ...
```

---

## Proof Strategy Architecture

### Strategy A: Finite-group / subgroup geometry for Miller–Rabin
**Most promising for Theorems 1–2.**

1. Factor `n - 1 = 2^s * d` with `d` odd, and define the set of bases satisfying the strong probable-prime conditions.
2. Show the strong liars sit inside a union of fibers of exponentiation maps in the unit group modulo `n`, or at least inside a set whose cardinality is controlled by a proper subgroup/coset argument.
3. Convert the existing bound theorems into a finset cardinality inequality; then use induction on `k` and product-cardinality lemmas to prove amplification.

Why promising: this aligns best with existing Miller–Rabin theorems and avoids heavy measure-theory/probability dependencies.

### Strategy B: CRT decomposition across prime-power factors
**Most promising for structural depth and nontrivial proofs.**

1. Decompose `ZMod n` via Chinese remainder ideas when `n` is composite and odd.
2. Analyze strong liar conditions componentwise across prime-power factors.
3. Show that the liar set loses at least a factor of 4 because at least one component forces a nontrivial exclusion.

Why powerful: this gives a conceptual proof of the quarter bound and naturally interfaces with AKS, since polynomial congruence modulo composite `n` also decomposes through factor rings.

### Strategy C: Polynomial-identity route for AKS
**Best for Theorem 3.**

1. Formalize polynomial congruence modulo `X^r - 1` over `ZMod n`.
2. Prove the prime case by the freshman’s dream/Frobenius endomorphism over characteristic `p`, then lift to prime `n`.
3. For the converse, show that if the congruence holds for enough `a`, then any composite divisor pattern contradicts the multiplicative-order side condition.

Why promising: it isolates the algebraic essence of AKS and can be built modularly, even if full runtime analysis is postponed.

### Strategy D: Spectral-energy contradiction
**Boldest, best for the cross-domain theorem.**

1. Associate to a large liar set a residue family with anomalously many modular collisions.
2. Invoke `spectral_energy_modular_collision_bound` to bound this collision energy.
3. Show the assumed liar abundance violates the spectral bound, yielding contradiction.

Why this matters: this is the new science-fiction leap. Even a partial theorem here would be far more original than a routine AKS formalization.

---

## Required Deep Proof Techniques

Your file must include at least 3 theorems proved using genuinely mathematical tactics such as:

- induction on `k` for amplification,
- `rcases` on parity / factorization / existence of prime divisors,
- `by_contra` in AKS correctness or spectral obstruction,
- `field_simp` where rational/cardinality inequalities are normalized,
- multi-step `calc` blocks transporting inequalities across cardinalities and powers.

Avoid vacuous proofs by computation. The point is to expose the mathematical mechanism.

---

## Cross-Domain Connections You Must Exploit

At least one theorem must explicitly connect primality testing to a different domain. Preferred directions:

1. **Additive combinatorics / spectral graph theory**  
   Use `spectral_energy_modular_collision_bound` to control pseudowitness regularity.

2. **Complexity theory / derandomization**  
   Interpret liar-set cardinality theorems as existence of small deterministic hitting sets for compositeness witnesses.

3. **Coding theory / certificate complexity**  
   View `AKSCertificate` as a formal error-detecting codeword for primality.

4. **Dynamical systems / finite-state evolution**  
   Regard repeated squaring in Miller–Rabin as orbit dynamics in `ZMod n`; prove a theorem about orbit stabilization implying witness failure.

A concrete cross-domain theorem suggestion:

```lean
theorem repeatedSquaring_orbit_eventually_periodic
    (n a : ℕ) (hcop : Nat.Coprime a n) :
    ∃ i < j, ((a : ZMod n) ^ (2^i)) = ((a : ZMod n) ^ (2^j))
```

Then use this orbit structure to reason about strong liar conditions. This ties primality testing to finite dynamical systems.

---

## Conjecture With Testable Prediction

You must state at least one falsifiable conjecture and give a computational test.

### Preferred conjecture
**Conjecture (spectral sparsity of strong liars):**  
For every odd composite `n` that is not a prime power, the additive energy of `StrongLiarSet n` inside `ZMod n` is strictly below the generic quarter-density model by a power-saving factor.

A Lean-friendly informal statement in `FUTURE_DIRECTIONS.md`:

> There exists `ε > 0` such that for infinitely many odd composite non-prime-powers `n`,
> `E(StrongLiarSet n) ≤ C * ((StrongLiarSet n).card ^ (3 - ε))`
> for a universal constant `C`.

**Computational falsification test:**  
For all odd composite `n ≤ B` (say `B = 10^4` in `demo.py`), explicitly compute:
- `StrongLiarSet n`,
- its cardinality,
- additive collision counts `(a+b) mod n = (c+d) mod n`,
and check whether the measured energy ever exceeds the conjectured threshold.

Alternative conjecture:
> Carmichael numbers maximize strong-liar spectral regularity among squarefree composites.

This is crisp and computationally testable.

---

## Verified Algorithm / Computational Method Requirement

You must deliver a verified algorithm, not just theorem statements.

### Required algorithmic deliverables
1. A certified Miller–Rabin checker for a fixed base:
   ```lean
   def isStrongProbablePrimeTo (n a : ℕ) : Bool := ...
   ```
   together with correctness lemmas relating the boolean to the mathematical predicate.

2. A k-round checker:
   ```lean
   def millerRabinCheck (n : ℕ) (bases : List ℕ) : Bool := ...
   ```
   with a theorem: if it returns `true` on all bases in a hitting set satisfying your hypotheses, then either `n` is prime or lies in a sharply bounded exceptional class.

3. A polynomial congruence checker for AKS windows:
   ```lean
   def aksPolyCheck (n r amax : ℕ) : Bool := ...
   ```
   with soundness theorem toward `AKSCertificate`.

4. A modular arithmetic simplification tactic or lemma collection for repeated-squaring congruences.

This is essential: the project should leave behind executable formal mathematics.

---

## Demo Expectations

Your `demo.py` should:
- let a user input `n`,
- run Miller–Rabin for selected bases,
- display the strong liar set up to some bound,
- estimate the empirical error rate,
- optionally visualize modular collision/spectral statistics of liar sets,
- run a small AKS-style polynomial congruence check for toy values.

Interactive comparison of:
- primes,
- Carmichael numbers,
- random odd composites,
is strongly encouraged.

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **`FUTURE_DIRECTIONS.md`**  
   Include **3–5 testable scientific hypotheses**, each falsifiable with a clear computational test. At least one must concern spectral/additive structure of strong liar sets, and at least one must concern deterministic hitting sets for Miller–Rabin bases.

2. **`RESEARCH_PAPER.md`**  
   A standalone scientific paper explaining:
   - the new definitions (`StrongLiarSet`, `AKSCertificate`, collision profile),
   - the main theorems,
   - proof architecture,
   - why this changes the formal landscape of primality testing,
   - what new research becomes possible.

3. **`ARTICLE.md`**  
   Scientific American style. Explain how randomness, algebra, and spectral structure collaborate to certify primality.

4. **A verified algorithm or computational method**  
   Specifically: certified Miller–Rabin checker + AKS polynomial checker + supporting modular arithmetic proof infrastructure.

5. **`demo.py`**  
   Interactive demonstration of the theory on explicit integers.

---

## Application Keywords

primality testing, Miller–Rabin, AKS, formal verification, Lean 4, Mathlib, derandomization, complexity theory, polynomial identity testing, finite fields, modular arithmetic, additive combinatorics, spectral methods, collision energy, pseudoprimes, Carmichael numbers, certificate complexity, certified algorithms, algebraic dynamics

---

## Final Call

Do not aim for “AKS formalized” as a museum piece. Aim for a new formal theory of **witness geometry** in primality testing: random witnesses, deterministic polynomial witnesses, and spectral obstructions all living in one Lean ecosystem. If you can prove even a partial version of the spectral obstruction theorem alongside a robust cardinality formalization of strong liars and an AKS certificate correctness theorem, you will have created a platform for future work on **formal derandomization of arithmetic algorithms**.

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

Research domain: Algebra
Research mode: prove
