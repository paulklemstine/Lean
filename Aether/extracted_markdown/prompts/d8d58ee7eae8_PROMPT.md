## Assignment: Primes of the Form \(n^2+1\)

Mode: **formalize + counterexample-aware + discover**

You should **not** pretend to prove the full conjecture
\[
\exists^\infty p\ \text{prime},\ \exists n,\ p=n^2+1,
\]
because this is a famous open problem. The breakthrough here is to turn that ambition into a mathematically honest, formally deep program that:

1. **formally rules out false targets**,  
2. **proves unconditional infinitude results for structured almost-primes of the form \(n^2+1\)**,  
3. **builds a Lean-ready bridge from elementary congruence obstructions to analytic sieve architecture**, and  
4. **connects \(n^2+1\) to the Friedlander–Iwaniec universe \(a^2+b^4\)**.

Your job is to produce a formal research package that would make future analytic number theory in Lean actually possible.

---

## Primary Objective: Replace the impossible headline by a formal breakthrough pipeline

### Critical honesty theorem
The statement “there are infinitely many primes of the form \(n^2+1\)” is currently open. So the first nontrivial theorem to formalize is a **meta-mathematical obstruction theorem** showing that the direct assignment target must be downgraded.

### Theorem A — Open-problem firewall
Formalize a theorem/documented result package asserting that no unconditional proof of infinitude of primes of the form \(n^2+1\) should be claimed in this project, and instead target rigorously provable surrogate theorems.

This is not a Lean theorem about arithmetic itself; it is a project-level theorem specification in `ARTICLE.md` / `RESEARCH_PAPER.md`. But inside Lean, you should replace the impossible target by exact unconditional theorems below.

---

## Main formal target 1: local obstruction and infinitude of admissible values

The polynomial \(f(n)=n^2+1\) has no fixed prime divisor. This is the local admissibility phenomenon behind every sieve attack.

### Theorem B — No fixed prime divisor for \(n^2+1\)
For every prime \(p\), there exists \(n\) such that \(p \nmid n^2+1\).

A sharper version:
\[
\forall p,\ \mathrm{Nat.Prime}\ p \to \exists n < p,\ (n^2+1)\bmod p \neq 0.
\]

### Suggested Lean 4 type signature
```lean
theorem exists_n_mod_prime_not_dvd_sq_add_one
    (p : ℕ) (hp : Nat.Prime p) :
    ∃ n : ℕ, n < p ∧ ¬ p ∣ (n^2 + 1)
```

A more modular finite-field version, likely more reusable:
```lean
theorem not_all_roots_X_sq_add_one_mod_prime
    (p : ℕ) (hp : Nat.Prime p) :
    ¬ ∀ n : Fin p, ((n.val^2 + 1) : ℕ) % p = 0
```

### Why this matters
This is the formal seed of sieve admissibility. In analytic number theory, one never starts by proving primality infinitude directly; one starts by proving the polynomial is not killed modulo every prime. This creates a rigorous bridge from elementary modular arithmetic to upper/lower bound sieve frameworks.

### Proof strategy options
1. **Root-counting over fields**  
   Over `ZMod p`, a nonzero polynomial of degree 2 has at most 2 roots. It cannot vanish on all residues mod \(p\).  
   Most promising if Mathlib’s polynomial-over-finite-field root bounds are available enough.

2. **Explicit witness by cases**  
   - If \(p=2\), choose \(n=0\): \(0^2+1=1\) not divisible by 2.
   - If \(p\) odd, test \(n=0,1,2\) and use congruence contradictions if all divide.  
   More elementary, perhaps easier to formalize.

3. **Pigeonhole + degree argument**  
   Show the polynomial \(X^2+1\) is not the zero polynomial in `ZMod p[X]`, hence cannot vanish at all points of `ZMod p`.  
   Best long-term infrastructure theorem.

### Cross-domain connection
This theorem is the exact arithmetic analogue of **non-degeneracy conditions in coding theory** and **identifiability in algebraic statistics**: a low-degree law cannot vanish on the entire state space unless it is structurally zero.

### Application keywords
`admissible polynomial`, `local obstruction`, `sieve theory`, `finite fields`, `polynomial root bound`, `analytic number theory infrastructure`

---

## Main formal target 2: infinitely many composite values with restricted prime support structure

A tractable theorem is to prove there are infinitely many \(n\) such that every prime divisor of \(n^2+1\) satisfies a rigid congruence constraint. For odd prime divisors \(q\mid n^2+1\), one has \(q\equiv 1\pmod 4\).

### Theorem C — Prime divisor congruence law for \(n^2+1\)
If \(q\) is an odd prime and \(q \mid n^2+1\), then \(q \equiv 1 \pmod 4\).

### Lean 4 type signature
```lean
theorem prime_dvd_sq_add_one_mod_four
    {q n : ℕ} (hq : Nat.Prime q) (hqodd : q ≠ 2)
    (hdiv : q ∣ (n^2 + 1)) :
    q % 4 = 1
```

Equivalent integer form:
```lean
theorem prime_dvd_sq_add_one_int_mod_four
    {q : ℕ} (hq : Nat.Prime q) (hqodd : q ≠ 2) {n : ℤ}
    (hdiv : (q : ℤ) ∣ (n^2 + 1)) :
    q % 4 = 1
```

### Why this is a breakthrough building block
This is the exact splitting law for primes in \(\mathbb{Z}[i]\): primes dividing norms \(n^2+1 = N(n+i)\) must split in the Gaussian integers. Formalizing this creates a bridge between elementary modular arithmetic and algebraic number theory in Lean, and it is the right precursor to any serious attack on Iwaniec/Friedlander–Iwaniec style results.

### Proof strategy options
1. **Multiplicative order argument**  
   From \(n^2 \equiv -1 \pmod q\), deduce \(n^4 \equiv 1\) but \(n^2 \not\equiv 1\), so the order of \(n\) mod \(q\) is 4. By Lagrange, \(4 \mid q-1\).  
   This is probably the cleanest Lean route.

2. **Euler criterion / quadratic reciprocity light**  
   \(-1\) is a quadratic residue mod \(q\), so \(q\equiv 1\pmod 4\).  
   Elegant, but may depend on available Mathlib lemmas about Legendre symbols.

3. **Gaussian integer norm viewpoint**  
   If \(q\mid n^2+1\), then \(q\) divides \(N(n+i)\), hence \(q\) splits in \(\mathbb{Z}[i]\), forcing \(q\equiv 1\pmod 4\).  
   Most visionary, but likely heavier than needed unless Gaussian integers are already convenient.

### Cross-domain connection
This is a **spectral selection rule**: only primes in one congruence class can appear, analogous to conservation laws in physics and allowed transition channels in quantum systems.

### Application keywords
`Gaussian integers`, `quadratic residues`, `splitting of primes`, `order modulo p`, `cyclotomic constraints`, `arithmetic geometry`

---

## Main formal target 3: infinitude of numbers with a prime factor \( \equiv 1 \pmod 4 \)

This is elementary but can be sharpened into a reusable infinitude theorem using your catalog theorem `eventual_lower_bound_gives_infinitely_many`.

### Theorem D — Infinitely many primes congruent to 1 mod 4 divide some value \(n^2+1\)
A concrete unconditional theorem:
\[
\forall B,\ \exists q>B,\ \mathrm{Nat.Prime}(q)\ \wedge\ q\equiv 1\pmod 4\ \wedge\ \exists n,\ q\mid n^2+1.
\]

This is equivalent to the infinitude of primes \(1 \bmod 4\), but phrased in a way tied directly to the \(n^2+1\) program.

### Lean 4 type signature
```lean
theorem infinitely_many_primes_one_mod_four_dividing_sq_add_one :
    ∀ B : ℕ, ∃ q > B, Nat.Prime q ∧ q % 4 = 1 ∧ ∃ n : ℕ, q ∣ (n^2 + 1)
```

### Why this matters
This theorem transforms the classical infinitude of primes \(1 \bmod 4\) into a statement intrinsic to the polynomial \(n^2+1\). It says the local splitting behavior required by the polynomial occurs infinitely often. This is a genuine bridge theorem between Euclid-style infinitude and polynomial value distribution.

### Proof strategy options
1. **From Fermat’s theorem on sums of two squares**  
   For \(q\equiv 1\pmod 4\), \(-1\) is a quadratic residue mod \(q\), so there exists \(n\) with \(n^2\equiv -1\pmod q\). Combine with infinitude of primes \(1 \bmod 4\).  
   Strong if Mathlib has enough residue theory.

2. **Euclid-style product argument using \(\prod p_i\)^2 + 1**  
   Assume finitely many such primes. Let \(N=(2\prod p_i)^2+1\). Any odd prime divisor \(q\mid N\) satisfies \(q\equiv 1\pmod 4\), but \(q\) is new.  
   This is likely the best self-contained formal route and beautifully tied to \(n^2+1\).

3. **Use `eventual_lower_bound_gives_infinitely_many` as an abstract infinitude engine**  
   First prove existence of arbitrarily large such primes by the Euclid-style construction, then feed into the catalog theorem.  
   Most aligned with the injected context.

### Cross-domain connection
This is a **generative adversarial construction** in arithmetic: build an object specifically designed to evade any finite blacklist of primes.

### Application keywords
`Euclid argument`, `sum of two squares`, `prime generation`, `quadratic residue`, `constructive infinitude`, `certified search`

---

## Main formal target 4: semiprime infrastructure inspired by Iwaniec

You likely cannot formalize Iwaniec’s full theorem in one cycle unless there is already substantial analytic number theory infrastructure. But you can formalize a **precise theorem schema** and prove finite, computable approximants.

### Formalization target E — Iwaniec theorem schema
Document and scaffold the target theorem:

\[
\exists^\infty n,\ \Omega(n^2+1)\le 2,
\]
where \(\Omega(m)\) counts prime factors with multiplicity.

This means infinitely many values of \(n^2+1\) are prime or semiprime. Since primality infinitude is open, this is the strongest classical unconditional result in the direction.

### Lean-facing definition targets
```lean
def bigOmega (n : ℕ) : ℕ := -- total number of prime factors with multiplicity

def IsSemiprime (n : ℕ) : Prop := ∃ p q : ℕ, Nat.Prime p ∧ Nat.Prime q ∧ p * q = n
```

Target theorem schema:
```lean
theorem iwaniec_sq_add_one_semiprime_infinitely_often :
    Set.Infinite {n : ℕ | bigOmega (n^2 + 1) ≤ 2}
```

If full proof is unreachable, prove the finite-data surrogate:
```lean
theorem exists_many_sq_add_one_with_bigOmega_le_two_up_to
    (B : ℕ) :
    ∃ n ≥ B, bigOmega (n^2 + 1) ≤ 2 ∨ True
```
but only as a temporary experimental placeholder, clearly labeled as non-final.

### Why this matters
Formalizing the **statement, definitions, and reduction lemmas** for Iwaniec is already field-opening. Lean has very little certified high-end sieve theory. Building the vocabulary for \(\Omega(n)\), semiprimes, weighted sieves, and polynomial sequences opens an entire new formal frontier.

### Proof strategy options
1. **Layered formalization strategy**  
   First formalize:
   - `bigOmega`,
   - multiplicativity lemmas,
   - divisor-sum majorants,
   - local density of \(n^2+1\) modulo primes,
   - abstract beta-sieve interfaces.  
   This is the most realistic and highest-leverage route.

2. **Computational-experimental certification**  
   Produce verified computation for large ranges of \(n\) exhibiting many semiprimes \(n^2+1\), then isolate the lemmas that any future proof must use.  
   Not a proof of infinitude, but excellent for `demo.py` and theorem discovery.

3. **Bridge through existing FI theorem formalization first**  
   If the asymptotic machinery for Friedlander–Iwaniec is somehow easier to modularize in Lean, use its bilinear-form/sieve framework as a template for the \(n^2+1\) sequence.  
   Visionary but likely harder.

### Cross-domain connection
This is where **complexity theory** and **formal verification** enter: semiprime-detection sits at the interface of number theory and cryptography, while sieve weights resemble sparse signal extraction in harmonic analysis.

### Application keywords
`semiprime`, `big Omega function`, `beta sieve`, `analytic number theory`, `cryptography`, `formal asymptotics`, `certified computation`

---

## Main formal target 5: bridge theorem to Friedlander–Iwaniec \(a^2+b^4\)

The real visionary move is not “also formalize another theorem.” It is to isolate the shared structural mechanism.

### Theorem F — Shared local admissibility framework
Define a general notion of an integer-valued polynomial family \(F(\mathbf{x})\) having **primitive local admissibility**:
\[
\forall p,\ \exists \mathbf{x},\ p \nmid F(\mathbf{x}).
\]
Then prove this for both
- \(F_1(n)=n^2+1\),
- \(F_2(a,b)=a^2+b^4\).

### Lean 4 type signature
```lean
def LocallyAdmissible1 (f : ℕ → ℕ) : Prop :=
  ∀ p : ℕ, Nat.Prime p → ∃ n : ℕ, ¬ p ∣ f n

def LocallyAdmissible2 (f : ℕ → ℕ → ℕ) : Prop :=
  ∀ p : ℕ, Nat.Prime p → ∃ a b : ℕ, ¬ p ∣ f a b

theorem sq_add_one_locally_admissible :
    LocallyAdmissible1 (fun n => n^2 + 1)

theorem a_sq_add_b_four_locally_admissible :
    LocallyAdmissible2 (fun a b => a^2 + b^4)
```

A stronger unification:
```lean
theorem polynomial_family_no_fixed_prime_divisor_bridge :
    LocallyAdmissible1 (fun n => n^2 + 1) ∧
    LocallyAdmissible2 (fun a b => a^2 + b^4)
```

### Why this is a breakthrough
This theorem identifies the **shared DNA** behind two of the most famous prime-producing forms in analytic number theory. It reframes the Friedlander–Iwaniec theorem and the \(n^2+1\) semiprime theorem as instances of a common admissibility-and-sieve paradigm. That is exactly the kind of formal abstraction that can open a new subfield in Lean: certified polynomial prime heuristics.

### Proof strategy options
1. **Explicit witnesses mod \(p\)**  
   For each prime \(p\), choose small values \(n\), or \((a,b)\), and show not all values vanish mod \(p\).  
   Easiest to formalize.

2. **Polynomial root bounds over finite fields**  
   For fixed \(b\), \(a^2+b^4\) is a quadratic in \(a\); similarly for fixed \(a\). Use degree bounds to show it cannot vanish identically.  
   More reusable.

3. **Algebraic geometry-lite viewpoint**  
   Show these are nonzero polynomial maps over `ZMod p`; their vanishing loci are proper subsets.  
   Most conceptually powerful.

### Cross-domain connection
This is analogous to **nontriviality of constraint manifolds** in dynamical systems and **avoidance of forbidden states** in statistical mechanics.

### Application keywords
`Friedlander-Iwaniec`, `admissibility`, `prime-producing polynomials`, `finite field geometry`, `sieve architecture`, `unified framework`

---

## Use the catalog aggressively

Especially use:

- `eventual_lower_bound_gives_infinitely_many`  
  Deploy it as the engine converting “for every bound \(B\), there exists \(x>B\) with property \(P\)” into a formal infinitude statement.

- `wilson_theorem'`  
  Potentially useful for modular residue constructions or primality-adjacent congruence manipulations, though likely secondary here.

The “dark primes” and speculative algebra theorems should be treated cautiously unless they directly help. Do not build the core arithmetic program on opaque speculative statements.

---

## Concrete file plan

Create a small theory stack, for example:

- `NumberTheory/SqAddOne/LocalAdmissibility.lean`
- `NumberTheory/SqAddOne/PrimeDivisorCongruence.lean`
- `NumberTheory/SqAddOne/InfinitelyManySplitPrimes.lean`
- `NumberTheory/SqAddOne/SemiprimeScaffolding.lean`
- `NumberTheory/SqAddOne/FriedlanderIwaniecBridge.lean`

Suggested theorem order:

1. `exists_n_mod_prime_not_dvd_sq_add_one`
2. `prime_dvd_sq_add_one_mod_four`
3. `infinitely_many_primes_one_mod_four_dividing_sq_add_one`
4. `sq_add_one_locally_admissible`
5. `a_sq_add_b_four_locally_admissible`
6. definitions: `bigOmega`, `IsSemiprime`
7. theorem schema stubs and reduction lemmas for Iwaniec

---

## Proof architecture: recommended route

### Strategy A — Elementary-to-structural escalation
1. Prove local admissibility for \(n^2+1\) and \(a^2+b^4\).
2. Prove the congruence law \(q\mid n^2+1 \Rightarrow q\equiv 1 \bmod 4\) for odd primes.
3. Use Euclid-style construction on values \(N^2+1\) to derive infinitude of relevant primes.

**Most promising**, because it yields unconditional, elegant theorems with current Mathlib-level tools.

### Strategy B — Finite field polynomial framework
1. Build a general lemma: a nonzero polynomial over a field has boundedly many roots.
2. Deduce local admissibility for the two polynomial families.
3. Package this as a reusable sieve precondition framework.

Best for long-term impact and abstraction.

### Strategy C — Analytic scaffold for future Iwaniec formalization
1. Define `bigOmega`, semiprime predicates, and weighted counting functions.
2. Prove elementary lemmas about factorization counts.
3. Build an interface layer for future sieve inequalities.

Best if your aim is to open the door to genuine analytic number theory in Lean.

---

## What would count as a genuine breakthrough this cycle

A successful cycle would include at least one of the following:

- a clean formal proof that every odd prime divisor of \(n^2+1\) is \(1 \bmod 4\),
- a formal infinitude theorem for primes \(q \equiv 1 \bmod 4\) realized as divisors of some \(n^2+1\),
- a reusable `LocallyAdmissible` abstraction covering both \(n^2+1\) and \(a^2+b^4\),
- a serious Lean scaffold for Iwaniec’s semiprime theorem, including precise definitions and reduction lemmas.

Do **not** waste the cycle on pretending to solve the open problem itself.

---

## Deliverables

Required:

- Lean 4 files with minimized `sorry`
- `FUTURE_DIRECTIONS.md`

Optional but encouraged:

- `ARTICLE.md` explaining the open-problem firewall and the unconditional theorems proved
- `RESEARCH_PAPER.md` presenting the admissibility bridge \(n^2+1 \leftrightarrow a^2+b^4\)
- `demo.py` for computational exploration of semiprimes \(n^2+1\)

---

## FUTURE_DIRECTIONS.md requirements

You must include **3–5 falsifiable hypotheses** with explicit tests.

### 1. Local-to-global sieve hypothesis
**Conjecture**: Any integer polynomial family formalized as `LocallyAdmissible` and satisfying a certified level-of-distribution axiom admits infinitely many values with `bigOmega ≤ 2`.  
**Test**: Instantiate on \(n^2+1\), \(a^2+b^4\), and one toy polynomial family already tractable in Lean.

### 2. Certified semiprime density hypothesis
**Conjecture**: The count of \(n \le X\) with `bigOmega (n^2+1) ≤ 2` exceeds \(C X / (\log X)^2\) for some explicit computable \(C>0\) over experimentally accessible ranges.  
**Test**: Use `demo.py` to fit lower bounds for increasing \(X\), then compare with proven toy-model inequalities.

### 3. Splitting-prime universality hypothesis
**Conjecture**: For every irreducible norm-form-like polynomial family \(F\), primes dividing values of \(F\) eventually lie in a finite union of Chebotarev-type congruence classes determined by the splitting field of \(F\).  
**Test**: Verify for \(n^2+1\) and candidate forms like \(a^2+b^4\) in finite computations and formal local lemmas.

### 4. Friedlander–Iwaniec bridge hypothesis
**Conjecture**: The minimal formal infrastructure needed for \(a^2+b^4\) primes already implies a reusable abstract theorem yielding local admissibility and prime-support congruence laws for \(n^2+1\).  
**Test**: Attempt to derive Theorems B/C/F from the abstract interface only.

### 5. Gaussian-integer factorization hypothesis
**Conjecture**: Recasting \(n^2+1\) as the norm \(N(n+i)\) in \(\mathbb{Z}[i]\) yields shorter Lean proofs of prime-support congruence laws than purely modular arithmetic.  
**Test**: Implement both proof styles and compare theorem dependency graph size and proof length.

---

## Final directive

Be bold, but be honest. The revolution here is not solving Landau’s problem by fiat. The revolution is to formalize the **correct architecture around it**: admissibility, congruence selection, infinitude of splitting divisors, and semiprime sieve scaffolding. If you do this well, you will have created one of the first credible launchpads for high analytic number theory in Lean.

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
hypotheses. Each direction must be a falsifiable claim or conjecture that
can be proved, disproved, or tested — not a vague "we could explore X."
Format: "Conjecture: [precise statement]. Test: [what would confirm or
refute it]. Impact: [what this would enable if true]." Every hypothesis
should be daring enough to matter and specific enough to fail.

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

Research domain: Speculative
Research mode: prove
