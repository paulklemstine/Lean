## Assignment: Arithmetic Phase Locking in Gradient Descent over Rational Polynomial Models

Mode: **prove / discover**

This is not an incremental exercise. You should carve out the first rigorous layer of an **arithmetic-dynamical theory of optimization**: gradient descent on rational polynomial losses viewed simultaneously as an algebraic self-map over `ℚ^n`, a discrete dynamical system over finite fields `𝔽_p`, and a probe of arithmetic monodromy. The central vision is that optimization trajectories carry hidden arithmetic signatures, and that “trainability” may admit a finite-field phase portrait invisible in classical real analysis.

Your goal is to prove **genuinely new theorems** that formalize a first nontrivial fragment of the phase-locking/equidistribution dichotomy, even if the full conjecture is out of reach. Do not merely restate orbit periodicity over finite sets; identify a structural criterion on polynomial update maps coming from gradients that forces arithmetic locking for infinitely many primes, or forces strong orbit-size lower bounds for all but finitely many primes.

Build on catalog theorems wherever relevant, especially results about:
- finite dynamical systems over `ZMod p`,
- polynomial maps and iteration,
- rational function reduction mod `p`,
- Jacobian/determinant criteria,
- orbit-counting in finite sets,
- algebraic number theory around good reduction,
- any catalog lemmas controlling gradients, polynomial evaluation, or reductions from `ℚ` / `ℤ` to finite fields.

You must explicitly cite the exact theorem/file names you use from the catalog and explain how they are deployed in the proof architecture.

---

## Core Mathematical Program

The broad conjecture is:

> For a Zariski-open family of polynomial loss functions `L : ℚ^n → ℚ` with rational initialization `w₀` and rational step size `η`, the gradient descent map
> `T(w) = w - η ∇L(w)`
> exhibits a dichotomy modulo primes: either  
> (i) for a set of primes of positive natural density, the reduction `T mod p` enters algebraic periodic or phase-locked behavior on the reduced forward orbit of `w₀`, or  
> (ii) for density-1 primes, the reduced orbit is asymptotically large/equidistributed in the forward-orbit subvariety;  
> and this dichotomy is governed by arithmetic monodromy / solvability of the Jacobian cocycle.

You are **not** expected to prove the full dichotomy. You are expected to prove a mathematically serious, structurally meaningful first-generation theorem package around it.

---

## Precise Formalization Targets

You must introduce at least one genuinely new definition capturing arithmetic phase locking.

### New Definitions to Introduce

Suggested definitions:

1. **Gradient update map over a commutative ring**
   - A structure encoding a polynomial loss and rational step size, together with its induced update map.

2. **Arithmetic phase locking at a prime**
   - A property that the reduction modulo `p` of the update map has a forward orbit from `w₀ mod p` that eventually lands in a cycle of bounded period, or more strongly lands in a cycle whose period divides a prescribed integer `m`.

3. **Primewise eventual period bound**
   - A predicate asserting the existence of `m : ℕ` such that for infinitely many / cofinitely many / positive-density many primes `p`, the reduced orbit has eventual period dividing `m`.

4. **Good reduction for rational polynomial gradient systems**
   - Excludes primes dividing denominators of coefficients and step size, and ensures the map reduces to a well-defined polynomial endomorphism over `ZMod p`.

A possible Lean-facing skeleton:

```lean
structure PolyGDSystem (n : ℕ) where
  loss : (Fin n → ℚ) → ℚ
  update : (Fin n → ℚ) → (Fin n → ℚ)
  step : ℚ
  is_gradient_form : Prop

def GoodPrime {n : ℕ} (S : PolyGDSystem n) (p : ℕ) : Prop := ...

def modpState (n : ℕ) (p : ℕ) := Fin n → ZMod p

def reducesTo {n : ℕ} (S : PolyGDSystem n) {p : ℕ} [Fact p.Prime] :
    modpState n p → modpState n p := ...

def EventuallyPeriodic {α : Type _} (f : α → α) (x : α) : Prop :=
  ∃ m k : ℕ, 0 < m ∧ Function.Iterate f (k + m) x = Function.Iterate f k x

def PhaseLockedModP {n : ℕ} (S : PolyGDSystem n) (w0 : Fin n → ℚ) (p : ℕ) : Prop := ...
```

If the full gradient formalization is too heavy in one cycle, define a more tractable surrogate:
- polynomial self-maps of `ℤ^n` arising from gradient descent templates,
- or affine/quadratic gradient systems where the gradient is explicit and certifiably polynomial.

That is acceptable **only if** the theorems remain nontrivial and conceptually aligned with the conjecture.

---

## Theorems You Should Prove

You must prove at least **3 deep theorems**. The following are strongly recommended because together they establish a real research narrative.

### Theorem 1: Good reduction and orbit compatibility
This is the formal gateway theorem: reduction modulo good primes commutes with iteration.

**Mathematical statement**

Let `T : ℤ^n → ℤ^n` be a polynomial update map induced by an integral polynomial loss and integral step-scaled gradient rule. For every prime `p` of good reduction and every `x ∈ ℤ^n`,
the reduction of the `t`-th iterate equals the `t`-th iterate of the reduction:
`(T^[t] x) mod p = (T_p^[t]) (x mod p)` for all `t`.

This theorem is not deep by itself, but it is foundational and should be proved by induction in a way that cleanly supports later arithmetic statements.

**Lean 4 type signature target**
```lean
theorem iterate_reduce_comm
  {n : ℕ} (T : (Fin n → ℤ) → (Fin n → ℤ))
  (Tp : (p : ℕ) → [Fact p.Prime] → (Fin n → ZMod p) → (Fin n → ZMod p))
  (hcompat :
    ∀ (p : ℕ) [Fact p.Prime] (x : Fin n → ℤ),
      (fun i => ((T x i : ℤ) : ZMod p)) = Tp p (fun i => (x i : ZMod p)))
  :
  ∀ (t : ℕ) (p : ℕ) [Fact p.Prime] (x : Fin n → ℤ),
    (fun i => (((Function.iterate T t x) i : ℤ) : ZMod p))
      = Function.iterate (Tp p) t (fun i => (x i : ZMod p))
```

**Why this matters**
This upgrades optimization dynamics to a legitimate arithmetic dynamical system. Without this theorem, every later statement about modular phase locking is ad hoc. With it, iteration over `ℚ/ℤ` and finite fields sits in one formal framework.

---

### Theorem 2: Uniform eventual periodicity over finite fields
Every self-map on a finite field state space has eventually periodic orbits, but your theorem must sharpen this in a way tailored to gradient systems.

**Mathematical statement**

Let `T_p : (𝔽_p)^n → (𝔽_p)^n` be the reduction of a good polynomial gradient update map. Then for every initial state `x`, the orbit is eventually periodic with preperiod and period both bounded by `p^n`. Moreover, if `T_p` is injective on the forward orbit closure of `x`, then the orbit is purely periodic.

**Lean 4 type signature target**
```lean
theorem eventuallyPeriodic_modp
  {n p : ℕ} [Fact p.Prime]
  (f : (Fin n → ZMod p) → (Fin n → ZMod p))
  (x : Fin n → ZMod p) :
  ∃ μ λ : ℕ, μ < p^n ∧ 0 < λ ∧ λ ≤ p^n ∧
    Function.iterate f (μ + λ) x = Function.iterate f μ x
```

and a stronger orbit-injectivity refinement:

```lean
theorem injective_on_orbit_implies_periodic
  {α : Type _} [Fintype α] [DecidableEq α]
  (f : α → α) (x : α)
  (hinj : Set.InjOn f {y | ∃ t : ℕ, Function.iterate f t x = y}) :
  ∃ λ : ℕ, 0 < λ ∧ Function.iterate f λ x = x
```

**Why this matters**
The raw finite-state argument is classical; the breakthrough is to package it in a way that makes phase locking a theorem schema for polynomial optimization maps modulo primes. This is the first rigorous statement that optimization trajectories over finite fields must organize into arithmetic attractors.

---

### Theorem 3: Arithmetic locking for affine-gradient systems
This should be your first genuinely substantive theorem, proving an infinite-prime locking phenomenon for a nontrivial class.

Take quadratic losses, so gradient descent becomes affine:
`L(w) = 1/2 wᵀ A w + bᵀ w + c`, hence
`T(w) = (I - ηA)w - ηb`.

Focus on the case where `M := I - ηA` has finite order over `ℚ` or is quasi-unipotent with controlled translation. Then modulo all sufficiently good primes, the orbit is periodic with period dividing an explicit integer depending only on `M`.

**Mathematical statement**

Suppose `M ∈ Mat_n(ℤ)` and `b ∈ ℤ^n`. Define `T(x)=Mx+b`. If there exists `m > 0` such that `M^m = I` and
`(I + M + ··· + M^(m-1)) b = 0`,
then for every prime `p`, the reduction `T_p` satisfies `T_p^m = id`, hence every orbit modulo `p` is periodic of period dividing `m`.

This is a clean exact theorem: it proves phase locking for an explicit algebraically characterized family.

**Lean 4 type signature target**
A matrix-heavy version may be ambitious, but you should aim as high as possible. A coordinatewise finite-dimensional function version is acceptable:

```lean
theorem affine_periodic_of_geom_sum_zero
  {n : ℕ}
  (M : (Fin n → ℤ) → (Fin n → ℤ))
  (b : Fin n → ℤ)
  (m : ℕ)
  (hM : Function.iterate M m = id)
  (hgeom : (fun x =>
      (Finset.range m).sum (fun k => Function.iterate M k b)) = 0) :
  ∀ x : Fin n → ℤ,
    Function.iterate (fun y i => M y i + b i) m x = x
```

If you can formalize this more naturally using matrices and linear maps, do so. A stronger and cleaner matrix theorem would be genuinely excellent.

**Why this matters**
This is the first exact theorem connecting:
- optimization (`quadratic loss`),
- algebraic dynamics (`affine self-map`),
- arithmetic phase locking (`uniform periodicity mod p`).

It realizes one side of the grand conjecture in a theorem with explicit hypotheses and algorithmic consequences.

---

### Theorem 4: Orbit-size lower bounds from invertible Jacobian / permutation behavior
You need at least one theorem pointing toward the “non-locking” side.

A feasible first result is:

**Mathematical statement**

If the reduction `T_p` is a bijection of `(𝔽_p)^n`, then every orbit is purely periodic. If in addition `T_p` is a single cycle on an invariant subset `V_p`, then the orbit of any point in `V_p` has size `|V_p|`. More realistically, prove lower bounds on orbit size from injectivity on the forward orbit or from affine maps with semisimple part of large multiplicative order.

For linear or affine systems, you can prove:
if `T_p(x)=M_p x+b_p` with `M_p ∈ GL_n(𝔽_p)` and the order of `M_p` is large, then every orbit in a suitable translated invariant subspace has period divisible by `ord(M_p)` or bounded below by it.

**Lean 4 type signature target**
A realistic target:
```lean
theorem periodic_of_bijective_finite
  {α : Type _} [Fintype α] [DecidableEq α]
  (f : α → α) (hf : Function.Bijective f) (x : α) :
  ∃ n > 0, Function.iterate f n x = x
```

Then specialize to modular affine maps.

**Why this matters**
This is your first formal bridge toward the equidistribution side: large-cycle or permutation-like behavior obstructs phase locking to short periods and suggests arithmetic mixing.

---

## Cross-Domain Connection Theorem

You are required to include at least one theorem connecting this arithmetic optimization story to another domain. Here are two strong options.

### Option A: Number theory + optimization + spectral algebra
For quadratic losses, connect periodic locking to roots of unity among eigenvalues of `I - ηA`.

**Theorem idea**
If `A` is diagonalizable over `ℚ̄` and all eigenvalues of `I - ηA` are roots of unity, then after clearing denominators the affine gradient update has bounded-period reduction modulo every sufficiently good prime.

This is a spectral-arithmetic criterion for phase locking.

### Option B: Physics/dynamical systems connection
Interpret the quadratic-loss gradient map as a discrete linear dissipative flow. Prove that arithmetic locking occurs exactly when the discrete-time propagator is torsion in the algebraic group generated by the update matrix. This links optimization to Floquet-type periodicity and arithmetic monodromy.

**Application keywords**
- arithmetic dynamics
- finite-field optimization
- algebraic monodromy
- modular phase locking
- polynomial iteration
- quadratic loss landscapes
- affine algebraic dynamics
- orbit structure over finite fields
- trainability diagnostics
- arithmetic chaos vs locking
- spectral torsion
- discrete Floquet theory

---

## Proof Strategy Architecture

You must present at least **2–3 proof strategies** and indicate which one you actually pursue for each theorem.

### Strategy A: Finite-state dynamical systems + orbit pigeonhole
Best for Theorems 1–2 and baseline modular periodicity.
1. Show good reduction commutes with the update map coordinatewise.
2. Prove by induction that reduction commutes with all iterates.
3. Use finiteness of `(Fin n → ZMod p)` to get orbit repetition.
4. Upgrade repetition to eventual periodicity via a calc chain on iterates.
5. Under injectivity/bijectivity assumptions, eliminate preperiod by contradiction.

Why promising:
- Lean-friendly,
- robust,
- gives a reusable engine for all modular orbit statements.

### Strategy B: Affine iteration formula + geometric series decomposition
Best for Theorem 3.
1. Derive the exact iterate formula
   `T^m(x) = M^m x + Σ_{k=0}^{m-1} M^k b`.
2. Impose `M^m = I` and vanishing geometric translation sum.
3. Conclude `T^m = id` over `ℤ`, hence after reduction modulo any good prime also `T_p^m = id`.
4. Deduce all orbits are periodic and uniformly phase-locked.

Why promising:
- conceptually sharp,
- yields explicit period bounds,
- directly reflects the arithmetic locking conjecture.

### Strategy C: Linear algebra / eigenvalue order / reduction modulo primes
Best for the spectral cross-domain theorem.
1. Express the quadratic gradient map as `x ↦ Mx+b`.
2. Use torsion or quasi-unipotent spectral assumptions on `M`.
3. Translate spectral torsion into iterate identities over `ℚ̄`, then descend to integral models after denominator clearing.
4. Reduce modulo primes of good reduction.

Why promising:
- opens the path to monodromy and Galois interpretations,
- closest to the grand conjecture,
- may require more library support but is the most visionary route.

**Most promising overall**
- Use **Strategy A** to build the formal infrastructure and secure deep theorems quickly.
- Use **Strategy B** for the flagship exact locking theorem.
- If time permits, use **Strategy C** for the cross-domain spectral criterion, even in a specialized diagonalizable or scalar case.

---

## Concrete Lean Guidance

Prefer a tractable formal core:
- start with maps on `Fin n → R`,
- then use `ZMod p` for modular reduction,
- use `Function.iterate`,
- use `Fintype.card` for finite-state orbit bounds,
- use induction for iterate formulas,
- use `rcases` on finite orbit repetition witnesses,
- use `by_contra` to force injective-orbit periodicity,
- use `field_simp` if rational step-size denominators appear,
- use `calc` chains for affine iterate expansions.

If full gradients of multivariate polynomials are too expensive to formalize in one cycle, formalize:
- affine maps arising from quadratic losses,
- or explicit polynomial update maps with certified integrality/good reduction.
But you must clearly state the path from this formal core to the full conjecture.

---

## Minimal Theorem Package Expected

At minimum, your file should contain:

1. A new definition of arithmetic phase locking / good reduction.
2. `iterate_reduce_comm` or equivalent.
3. `eventuallyPeriodic_modp` with nontrivial proof.
4. A theorem proving **uniform periodic locking** for an explicit nontrivial class of affine/quadratic gradient systems.
5. One cross-domain theorem relating locking to spectral torsion / roots of unity / algebraic group structure.
6. One falsifiable conjecture with computational test.

These should not be toy statements. At least 3 proofs must genuinely use:
- induction,
- `rcases`,
- `by_contra`,
- `field_simp`,
- or multi-step `calc`.

---

## Falsifiable Conjectures and Testable Predictions

You must include a `FUTURE_DIRECTIONS.md` containing **3–5 testable scientific hypotheses**. At least one should be:

### Conjecture A: Spectral torsion predicts positive-density locking
For quadratic losses `L(w)=1/2 wᵀAw+bᵀw+c` over `ℚ`, with `T(w)=(I-ηA)w-ηb`, if the semisimple part of `I-ηA` has all eigenvalues roots of unity, then there exists `m > 0` such that for a positive-density set of good primes `p`, every reduced orbit has period dividing `m`.

**Computational test**
- Sample rational quadratic models.
- Compute `M=I-ηA`.
- Numerically/symbolically estimate whether eigenvalues are roots of unity.
- For many primes `p`, compute orbit periods of random initial states.
- Compare locking density with the spectral criterion.

**Refutation**
A family with non-root-of-unity semisimple part but persistent bounded-period locking on positive-density primes, or root-of-unity semisimple part with no such locking.

### Conjecture B: Large Galois/monodromy implies long modular orbits
For generic polynomial losses of bounded degree, if the arithmetic monodromy of the update map is not virtually solvable, then for density-1 good primes, the reduced orbit length from generic `w₀` grows at least like `p^δ` for some `δ>0`.

### Conjecture C: Arithmetic locking correlates with flat critical skeletons
Polynomial losses with highly resonant Hessian spectra near critical skeletons should display elevated prime-density phase locking compared to generic Morse losses.

---

## Deliverables You Must Produce

You must produce **all** of the following:

1. **Lean file(s)** with the new definitions and at least 3 substantial theorems proved with deep tactics.
2. **FUTURE_DIRECTIONS.md**
   - 3–5 falsifiable hypotheses,
   - each with a concrete computational test and explicit refutation criterion.
3. **RESEARCH_PAPER.md**
   - standalone scientific exposition,
   - motivation from optimization + arithmetic dynamics,
   - precise theorem statements,
   - proof ideas,
   - why this opens a field,
   - what to test next.
4. **ARTICLE.md**
   - Scientific American style,
   - explain how gradient descent can “lock onto arithmetic rhythms” modulo primes,
   - make the finite-field view of optimization vivid and intuitive.
5. **A verified algorithm or computational method**
   - e.g. algorithm to detect modular phase locking for affine/quadratic gradient systems,
   - or algorithm to compute orbit periods modulo primes and compare to spectral torsion data.
6. **demo.py**
   - interactively sample quadratic/polynomial losses,
   - reduce modulo primes,
   - plot orbit lengths / period histograms / locking densities,
   - compare against spectral or monodromy proxies.

---

## Experimental / Algorithmic Component

A particularly strong verified algorithm would be:

### Algorithm: Modular Phase Locking Detector
Input:
- rational quadratic or polynomial loss,
- rational step size `η`,
- rational initialization `w₀`,
- prime range `p ≤ P`.

Output:
- good primes,
- eventual period and preperiod modulo each prime,
- empirical locking density for period dividing `m`,
- spectral proxy from `I-ηA` in the quadratic case.

Desired theorem-backed guarantee:
- for affine systems satisfying the torsion criterion, the detector proves period divides `m` for every good prime;
- otherwise it gives empirical evidence toward the non-locking side.

This algorithm is not auxiliary—it is part of the science. It turns the conjecture into a falsifiable program.

---

## What Would Count as a Breakthrough Here

A breakthrough is not “all finite orbits over finite fields are eventually periodic.” That is only infrastructure.

A breakthrough is:
- a structurally meaningful theorem showing **why** a class of optimization maps must phase-lock modulo infinitely many primes,
- an exact algebraic criterion for this locking,
- a cross-domain spectral or monodromy interpretation,
- and a computational pipeline that can test the conjectural dichotomy on real families.

If you can prove even a specialized theorem of the form

> “For quadratic rational losses, arithmetic phase locking modulo all good primes is equivalent to torsion of the semisimple part of the update operator, under explicit nondegeneracy hypotheses,”

you will have created the first rigorous bridge between optimization theory and arithmetic dynamics.

That is the target energy.

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
