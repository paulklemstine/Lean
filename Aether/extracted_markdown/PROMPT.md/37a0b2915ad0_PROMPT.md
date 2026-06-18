## Assignment: **Mode = prove / discover**
**Conjectural program:** turn Beal obstruction theory into a genuinely local-global theory of primitive residue nonexistence, with a formal CRT engine in Lean 4 and a computationally certifiable obstruction search for signature `(3,3,3)`.

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

### Research Direction
# Future Directions: Falsifiable Hypotheses for Beal Obstruction Theory

The core opportunity is not merely to brute-force small moduli, but to prove that the obstruction landscape is structurally governed by Chinese remainder factorization, unit-group power maps, and local image-avoidance phenomena in `(ℤ/Nℤ)ˣ`. If formalized correctly, this opens a new arithmetic-combinatorial framework: **finite residue obstructions as a standalone route to excluding primitive exponential Diophantine equations**, independent of FLT-level global machinery.

---

## Hypothesis 1: Finite Covering Hypothesis for Signature `(3,3,3)`

**Conjecture:** There exists a modulus `N ≤ 10^6` such that `PrimitiveResidueSolution N 3 3 3` is false; equivalently, no units modulo `N` satisfy
\[
a^3 + b^3 \equiv c^3 \pmod N.
\]

This should be elevated from a computational conjecture to a theorem schema about cubic image sets in unit groups.

### Precise theorem target
If your current development defines
```lean
PrimitiveResidueSolution : ℕ → ℕ → ℕ → ℕ → Prop
```
with `PrimitiveResidueSolution N x y z` meaning there exist unit residues `a b c (mod N)` such that
`a^x + b^y ≡ c^z [MOD N]`,
then aim for a theorem of the following form:

```lean
theorem exists_small_cubic_obstruction :
  ∃ N : ℕ, 2 ≤ N ∧ N ≤ 10^6 ∧ ¬ PrimitiveResidueSolution N 3 3 3
```

If the computational infrastructure is not yet ready for `10^6`, first prove the structural reduction theorem:

```lean
theorem cubic_obstruction_of_prime_power_obstruction
    {N : ℕ} (hN : 2 ≤ N) :
    (∃ p k : ℕ, Nat.Prime p ∧ 1 ≤ k ∧ p^k ∣ N ∧ ¬ PrimitiveResidueSolution (p^k) 3 3 3) →
    ¬ PrimitiveResidueSolution N 3 3 3
```

and then instantiate it computationally from a certified obstructing modulus.

A stronger breakthrough theorem would classify a family of obstructing primes:

```lean
theorem no_primitive_cubic_solution_mod_p_of_condition
    {p : ℕ} (hp : Nat.Prime p) (hcond : /* explicit cubic-image condition on ZMod p */) :
    ¬ PrimitiveResidueSolution p 3 3 3
```

The exact `hcond` should be extracted from additive combinatorics of the cube subgroup in `(ZMod p)ˣ`.

### Why this would be a breakthrough
A single certified modulus excluding primitive cube-sum residues gives a **finite obstruction certificate** for the primitive equation `A^3 + B^3 = C^3` under coprimality-to-`N`. But the deeper prize is conceptual: if such obstructions are abundant, then Beal-type impossibility may be attacked through **local image sparsity** rather than deep global descent. This would create a new field of “modular obstruction geometry” for exponential Diophantine equations.

### Proof strategy options

#### Strategy A: Unit-image additive combinatorics in `ZMod p`
1. For prime `p`, define the cubic image set
   \[
   C_p := \{u^3 : u \in (\mathbb{Z}/p\mathbb{Z})^\times\}.
   \]
   Then `PrimitiveResidueSolution p 3 3 3` is equivalent to
   \[
   (C_p + C_p) \cap C_p \neq \varnothing
   \]
   inside `ZMod p`, with all elements restricted to units.
2. Analyze when `C_p` is a proper subgroup of `(ZMod p)ˣ` and whether additive self-intersection can avoid `C_p`.
3. Search for a structural criterion on `p mod 3` or on character sums implying
   \[
   C_p + C_p \subseteq (\mathbb{Z}/p\mathbb{Z}) \setminus C_p.
   \]

**Why promising:** This reframes the problem as a sumset-avoidance theorem in finite fields, connecting directly to additive combinatorics and multiplicative character methods.

#### Strategy B: Prime-power lifting / obstruction persistence
1. Prove that nonexistence modulo `p` implies nonexistence modulo some `p^k`, or conversely that certain `p^k` admit sharper obstructions than `p`.
2. Use the unit structure of `ZMod (p^k)` and lifting properties of cube maps on principal units.
3. Push obstructions from prime powers to arbitrary composite moduli via CRT.

**Why promising:** Even if no prime modulus obstructs `(3,3,3)`, prime powers may. This is the natural route if the local obstruction is genuinely `p`-adic rather than finite-field.

#### Strategy C: Certified exhaustive theorem
1. Build a computable decision procedure for `PrimitiveResidueSolution N 3 3 3`.
2. Prove its correctness in Lean.
3. Evaluate it on a strategically selected set of moduli, ideally all prime powers up to a bound, and extract a theorem by reflection.

**Why promising:** This gives an unconditional formal theorem quickly if the obstruction exists in the tested range. It is less conceptually deep than A/B, but it can seed the deeper theory.

**Most promising path:** Start with **B + CRT**, because persistence and factorization theorems are likely already closest to your catalog infrastructure. Then layer **A** to explain *why* obstructions should exist.

### Cross-domain connections
- **Additive combinatorics:** sumsets of multiplicative subgroups in finite fields.
- **Local-global arithmetic:** residue obstructions as a finite analogue of Hasse principles.
- **Computational number theory:** certified search over `ZMod N` unit groups.
- **Complexity theory:** obstruction existence may reduce infinite Diophantine impossibility to finite certificate search.
- **Coding theory / pseudorandomness:** cubic image sets behave like structured sparse subsets with detectable additive bias.

### Application keywords
`Beal conjecture`, `finite obstruction`, `CRT`, `ZMod`, `unit group`, `cube residues`, `additive combinatorics`, `local-global principle`, `formal verification`, `certified computation`

---

## Hypothesis 2: CRT Compression Efficiency Hypothesis

**Conjecture:** For pairwise coprime moduli `M₁, …, Mₖ` with `N = ∏ Mᵢ`,
\[
\mathrm{PrimitiveResidueSolution}(N,x,y,z)
\iff
\forall i,\ \mathrm{PrimitiveResidueSolution}(M_i,x,y,z).
\]

This should not remain a conjecture. It is the foundational local-global theorem of the subject.

### Precise theorem statement
First prove the binary case:

```lean
theorem primitiveResidueSolution_mul_iff
    {M N x y z : ℕ}
    (hM : 1 < M) (hN : 1 < N) (hcop : Nat.Coprime M N) :
    PrimitiveResidueSolution (M * N) x y z ↔
      PrimitiveResidueSolution M x y z ∧ PrimitiveResidueSolution N x y z
```

Then derive the finite-family version, perhaps over a list/product:

```lean
theorem primitiveResidueSolution_prod_iff
    {ι : Type} [Fintype ι]
    (M : ι → ℕ) (x y z : ℕ)
    (hpair : Pairwise (Nat.Coprime on M))
    (hgt : ∀ i, 1 < M i) :
    PrimitiveResidueSolution (∏ i, M i) x y z ↔
      ∀ i, PrimitiveResidueSolution (M i) x y z
```

If the current formalization uses divisibility or modular congruence directly rather than `ZMod`, the theorem may be easier to state in terms of witnesses `a b c` and `IsUnit`-style coprimality predicates.

### Why this would be a breakthrough
This theorem is the **compression law** for the entire obstruction program. It says the search for primitive residue solutions is completely local at pairwise coprime factors. Then:
- obstruction search reduces to prime powers,
- existence search decomposes into independent local solvers,
- negative results become compositional.

This is the arithmetic backbone of a future “residue obstruction compiler.”

### Proof strategy options

#### Strategy A: Direct witness projection and CRT reconstruction
1. Forward direction: reduce witnesses modulo each factor; unitness descends because `gcd(a, MN)=1` implies `gcd(a,M)=gcd(a,N)=1`.
2. Reverse direction: choose local witnesses modulo `M` and `N`.
3. Use CRT to reconstruct `a, b, c mod MN`; prove they remain units modulo `MN`; combine congruences.

**Why promising:** This is the cleanest and most canonical route. It should align with existing `Nat.ModEq`, `ZMod`, and CRT lemmas in Mathlib.

#### Strategy B: Recast in product rings
1. Use the ring isomorphism
   \[
   \mathbb{Z}/(MN)\mathbb{Z} \cong \mathbb{Z}/M\mathbb{Z} \times \mathbb{Z}/N\mathbb{Z}
   \]
   for coprime `M, N`.
2. Show the primitive predicate is exactly existence of unit triples satisfying a polynomial equation in the ring.
3. Transfer existence across the isomorphism.

**Why promising:** This is mathematically superior and scales to arbitrary polynomial obstruction predicates, not just `a^x+b^y=c^z`.

#### Strategy C: Factor through the unit group functor
1. Work entirely in `(ZMod n)ˣ`.
2. Define a predicate
   \[
   \exists u,v,w \in (ZMod n)^\times,\ \bar u^x + \bar v^y = \bar w^z.
   \]
3. Use the multiplicative equivalence
   \[
   (ZMod(MN))^\times \simeq (ZMod M)^\times \times (ZMod N)^\times
   \]
   induced by CRT.

**Why promising:** Best for later generalization to higher-arity equations and group-structured residue constraints.

**Most promising path:** **B** if your current code already uses `ZMod`; otherwise **A** as the shortest route to a theorem. But architect the proof so it can later be upgraded to a generic polynomial-constraint CRT theorem.

### Cross-domain connections
- **Sheaf/locality viewpoint:** primitive residue solvability behaves like a local section condition over the spectrum of `ℤ/Nℤ`.
- **Constraint satisfaction / SAT decomposition:** CRT turns one arithmetic CSP into independent local CSPs.
- **Algebraic geometry over finite rings:** existence of unit-valued points on affine hypersurfaces factors over connected components.
- **Category theory:** functoriality of solution predicates under product decompositions.

### Application keywords
`Chinese remainder theorem`, `local-global`, `prime power reduction`, `unit-valued solutions`, `finite ring geometry`, `constraint decomposition`, `formalized arithmetic`

---

## Hypothesis 3: Linear ABC Threshold Hypothesis

**Conjecture:** There exists a universal constant `α ≤ 3` such that `IntAbcBound K` implies no primitive Beal solution whenever the exponents are sufficiently large relative to `K`, with a linear threshold in the exponent sum or minimum exponent.

This needs sharpening into a theorem that cleanly interfaces with your existing ABC formalization.

### Precise theorem target
Assuming your catalog already contains a predicate of the form
```lean
IntAbcBound : ℝ → Prop
```
or similar, and a notion of primitive Beal solutions such as
```lean
PrimitiveBealSolution : ℤ → ℤ → ℤ → ℕ → ℕ → ℕ → Prop
```
aim for a theorem schema like:

```lean
theorem no_primitive_beal_of_abc_linear_threshold
    {K α : ℝ}
    (habc : IntAbcBound K)
    (hα : α ≤ 3) :
    ∃ B : ℕ, ∀ {A B' C x y z : ℕ},
      B ≤ min x (min y z) →
      PrimitiveBealSolution A B' C x y z →
      False
```

This is still schematic. The real target should expose the quantitative dependence of the exponent threshold on the ABC constant. If your existing ABC theorem already gives a bound of the shape
\[
C^r < K \cdot \mathrm{rad}(ABC)^s,
\]
then derive an explicit contradiction whenever exponents exceed a linear function of `K` or `log K`.

A more realistic intermediate theorem is:

```lean
theorem exponent_bound_of_abc
    {K : ℝ} (habc : IntAbcBound K) :
    ∃ T : ℕ, ∀ {A B C x y z : ℕ},
      PrimitiveBealSolution A B C x y z →
      T ≤ min x (min y z) →
      False
```

### Why this would be a breakthrough
This bridges two worlds usually treated separately:
- **finite residue obstruction theory**, which is local and combinatorial,
- **ABC-style global height bounds**, which are analytic and asymptotic.

If formalized together, this yields a two-engine architecture:
1. ABC kills large exponents.
2. Residue obstructions kill small exponents.
Combined, they could produce a modular route to broad Beal-type impossibility theorems.

### Proof strategy options

#### Strategy A: Extract explicit exponent growth from radical bounds
1. Expand the primitive equation
   \[
   A^x + B^y = C^z
   \]
   under gcd assumptions.
2. Use the catalog’s ABC inequality to bound `C^z` by a radical expression in `ABC`.
3. Compare powers to radicals using `rad(A^x B^y C^z) = rad(ABC)` and derive a contradiction for large exponents.

**Why promising:** This is the standard conceptual route and should interact directly with any existing `IntAbcBound` lemmas.

#### Strategy B: Normalize by the maximal base and derive a linear exponent barrier
1. Assume `C = max(A,B,C)` after relabeling.
2. Translate the equation into
   \[
   C^z \le A^x + B^y \le 2C^{m}
   \]
   for a suitable `m < z` under primitive constraints.
3. Combine with ABC to force `z` below an explicit threshold.

**Why promising:** Better for producing a numerically usable linear bound.

#### Strategy C: Hybrid local-global contradiction
1. Use ABC to reduce to finitely many exponent signatures.
2. For each remaining signature, invoke residue obstructions via Hypotheses 1 and 2.
3. Conclude a finite-check theorem schema.

**Why promising:** This is the most visionary route: it converts a deep asymptotic conjecture into a finite formal verification pipeline.

**Most promising path:** **A first**, because it should produce a theorem with the least new infrastructure. Then pursue **C**, which is the actual paradigm shift.

### Cross-domain connections
- **Diophantine geometry:** ABC as a height principle.
- **Proof mining / explicit constants:** extracting executable thresholds from existential global bounds.
- **Formal methods:** combining analytic inequalities with finite certified search.
- **Complexity theory:** reducing infinite search spaces to bounded certificate checks.

### Application keywords
`abc conjecture`, `Beal conjecture`, `height bounds`, `radical function`, `explicit threshold`, `formal Diophantine analysis`, `hybrid local-global method`

---

## Additional theorem you should strongly consider proving
To make Hypotheses 1 and 2 scientifically usable, formalize the monotonicity of obstruction under divisibility:

```lean
theorem no_primitiveResidueSolution_of_dvd
    {M N x y z : ℕ}
    (hdiv : M ∣ N)
    (hno : ¬ PrimitiveResidueSolution M x y z) :
    ¬ PrimitiveResidueSolution N x y z
```

This is the contrapositive of solution inheritance from `N` to divisors. It is strategically crucial because one obstructing modulus annihilates all of its multiples.

A companion theorem in the positive direction:

```lean
theorem primitiveResidueSolution_of_factors
    {M N x y z : ℕ}
    (hcop : Nat.Coprime M N)
    (hM : PrimitiveResidueSolution M x y z)
    (hN : PrimitiveResidueSolution N x y z) :
    PrimitiveResidueSolution (M * N) x y z
```

Together with the `iff` theorem above, this yields a full algebra of obstructions.

---

## Building on catalog theorems
Use any existing divisor inheritance theorem as the forward half of CRT compression. If the catalog already contains a result of the form

```lean
primitiveResidueSolution_of_dvd
```
or
```lean
PrimitiveResidueSolution.monotone
```

then:
1. identify the exact statement,
2. use it for the easy direction of `primitiveResidueSolution_mul_iff`,
3. isolate the reverse direction as the genuinely new theorem.

Likewise, if there are already lemmas about `Nat.ModEq`, `ZMod`, unit lifting, or CRT isomorphisms, build the proof over those rather than unfolding congruence arithmetic manually.

If the ABC catalog contains any theorem relating `IntAbcBound K` to inequalities involving `rad`, `gcd`, or primitive sums, make that theorem the launch point for the linear-threshold extraction. Do not reprove foundational ABC machinery if a quantitative bridge theorem already exists.

---

## Deliverables
1. At least one major theorem from Hypothesis 2 fully proved in Lean, ideally `primitiveResidueSolution_mul_iff`.
2. One obstruction-propagation theorem under divisibility.
3. Either:
   - a certified existence theorem `∃ N ≤ 10^6, ¬ PrimitiveResidueSolution N 3 3 3`, or
   - a structural prime / prime-power obstruction criterion.
4. If possible, one explicit ABC-threshold theorem, even in weaker quantitative form.

Minimize `sorry`; if computation is needed, ensure the decision procedure is correctness-certified.

---

## FUTURE_DIRECTIONS.md requirement
Produce a structured `FUTURE_DIRECTIONS.md` with **3–5 falsifiable scientific hypotheses**, each with:
- a precise conjecture,
- a concrete test protocol,
- a refutation criterion,
- and expected significance.

Include at least these candidate hypotheses, sharpened as needed:

1. **Prime-power cubic sparsity hypothesis:**  
   There exist infinitely many primes `p` or prime powers `p^k` such that `¬ PrimitiveResidueSolution (p^k) 3 3 3`.  
   **Test:** compute for primes / prime powers up to a bound and look for infinite-family congruence patterns.

2. **Uniform local-global polynomial predicate hypothesis:**  
   Any predicate of the form “there exist units solving a fixed polynomial equation over `ZMod N`” factors over coprime products exactly as in Hypothesis 2.  
   **Test:** generalize the CRT proof from monomial exponents to arbitrary multivariate integer polynomials.

3. **ABC + residue hybrid finiteness hypothesis:**  
   Under `IntAbcBound K`, every primitive Beal counterexample must lie in a finite, explicitly computable set of exponent signatures.  
   **Test:** derive an explicit threshold from ABC and enumerate the surviving signatures.

4. **Character-sum obstruction criterion hypothesis:**  
   There exists a multiplicative-character criterion on primes `p` guaranteeing `¬ PrimitiveResidueSolution p 3 3 3`.  
   **Test:** compare computed obstructing primes against cubic character statistics.

5. **Residue obstruction density hypothesis:**  
   The set of obstructing moduli for `(3,3,3)` has positive lower density among squarefree integers.  
   **Test:** use the CRT factorization theorem plus empirical counts of obstructing primes.

This document is not optional; it is the mechanism for turning the current theorem into a research program.

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
