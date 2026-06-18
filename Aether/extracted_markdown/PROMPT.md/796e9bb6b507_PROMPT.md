## Assignment: We have formally verified the following:

Prove new, non-trivial theorems. Build on catalog theorems. Minimize `sorry`.

## Mode: prove / discover

## Research Direction
# Future Directions: Perfect Cuboid Modular Sieve Program

## Summary of Established Results

We have formally verified the following:
- **Mod-105 sieve**: Exactly `14,245` out of `1,157,625` residue classes mod `105` survive the four quadratic residue conditions (face + space diagonals). This is a density collapse to `1.23%`.
- **CRT multiplicativity**: The count factorizes as `7 × 37 × 55`, perfectly matching the product of individual prime counts at `3`, `5`, and `7`. This means the quadratic residue conditions are independent across these primes.
- **Space diagonal obstruction**: At mod `7`, the space diagonal kills `24` additional face-diagonal survivors (from `79` to `55`), a `30.4%` reduction.
- **Bridge theorem**: Any integer perfect cuboid must have residues in one of these `14,245` classes.

This is already more than a computational filter: it is the beginning of an **adelic obstruction theory** for the perfect cuboid problem. The next step is to force Aristotle to decide whether this sieve is merely computationally useful, or whether it reflects a genuine Euler-product law for local solvability densities.

---

## Breakthrough Objective 1: Prime-by-prime Euler factorization of the cuboid residue sieve

### Precise theorem target

Define, for `n : ℕ`, the set of residue triples `(x,y,z) ∈ (ZMod n)^3` satisfying that
- `x^2 + y^2` is a square mod `n`,
- `x^2 + z^2` is a square mod `n`,
- `y^2 + z^2` is a square mod `n`,
- `x^2 + y^2 + z^2` is a square mod `n`.

Let `survivorCount n` be the cardinality of this set.

The theorem to prove is:

> **Theorem (CRT factorization of cuboid survivors).**  
> For all coprime moduli `m n`,  
> \[
> \gcd(m,n)=1 \;\Longrightarrow\; \mathrm{survivorCount}(mn)
>   = \mathrm{survivorCount}(m)\,\mathrm{survivorCount}(n).
> \]
> In particular, for any squarefree modulus `N = ∏ p_i`,
> \[
> \mathrm{survivorCount}(N)=\prod_i \mathrm{survivorCount}(p_i).
> \]

This is the correct structural theorem. If formalized cleanly, it turns the mod-105 computation from an isolated fact into the first nontrivial case of a general **local-global counting principle**.

### Lean 4 type signature target

You should aim for something of the form:

```lean
def CuboidSurvivor (n : ℕ) (t : (ZMod n) × (ZMod n) × (ZMod n)) : Prop := 
  IsSquare (let (x,y,z) := t; x^2 + y^2) ∧
  IsSquare (let (x,y,z) := t; x^2 + z^2) ∧
  IsSquare (let (x,y,z) := t; y^2 + z^2) ∧
  IsSquare (let (x,y,z) := t; x^2 + y^2 + z^2)

def survivorSet (n : ℕ) : Finset ((ZMod n) × (ZMod n) × (ZMod n)) := ...
def survivorCount (n : ℕ) : ℕ := (survivorSet n).card

theorem survivorCount_mul_of_coprime
    {m n : ℕ} (hcop : Nat.Coprime m n) :
    survivorCount (m * n) = survivorCount m * survivorCount n := ...
```

If `IsSquare` over `ZMod n` is awkward, define a residue-square predicate by existential quantification:

```lean
def SquareMod (n : ℕ) (a : ZMod n) : Prop := ∃ t : ZMod n, t^2 = a
```

Then use that instead. The theorem is still the same.

### Why this would be a breakthrough

Because it upgrades the modular sieve from a finite computation to a **multiplicative density theory**. Once the count is proven multiplicative, every new prime gives a genuine Euler factor. That opens the door to:
- asymptotic density decay,
- explicit search complexity estimates,
- local obstruction heuristics analogous to Hardy–Littlewood products,
- and eventually a rigorous statement that admissible residue classes have density tending to zero along squarefree moduli.

This would be the first serious step toward treating perfect cuboids with the same local-statistical toolkit used in rational points, Selmer sieves, and arithmetic statistics.

### Proof strategy options

#### Strategy A: Direct CRT transport of the square predicate
1. Prove that for coprime `m n`, the ring equivalence  
   `ZMod (m*n) ≃+* ZMod m × ZMod n`
   transports `SquareMod (m*n)` exactly to coordinatewise squareness.
2. Show `CuboidSurvivor (m*n)` is equivalent to the product predicate  
   `CuboidSurvivor m ∧ CuboidSurvivor n` under the CRT equivalence on triples.
3. Deduce cardinality multiplicativity from a bijection of finite types / finsets.

**Most promising**: this is conceptually clean and aligns perfectly with Mathlib’s CRT infrastructure.

#### Strategy B: Finite-set factorization via explicit witness lifting
1. For each square condition mod `m*n`, unpack witnesses `a^2`, `b^2`, etc.
2. Project witnesses mod `m` and `n`.
3. Conversely, given square witnesses modulo `m` and `n`, lift them via CRT to a witness mod `m*n`.
4. Package the four lifted witnesses simultaneously to build a survivor modulo `m*n`.

This is more elementary and may be easier if typeclass issues around ring equivalences become annoying.

#### Strategy C: Predicate-level multiplicativity in a general abstract lemma
1. Prove a general theorem: any conjunction of polynomial square conditions over `ZMod n` is multiplicative over coprime moduli.
2. Instantiate it with the four cuboid polynomials:
   - `X^2 + Y^2`
   - `X^2 + Z^2`
   - `Y^2 + Z^2`
   - `X^2 + Y^2 + Z^2`
3. Recover cuboid multiplicativity as a corollary.

This is the most revolutionary route: it would create reusable infrastructure for **polynomial local sieve theory** in Lean.

---

## Breakthrough Objective 2: Add prime 11 and formalize the first new Euler factor

### Precise theorem target

> **Theorem (mod-1155 factorization).**  
> Let `1155 = 3 * 5 * 7 * 11`. Then
> \[
> \mathrm{survivorCount}(1155)
> = \mathrm{survivorCount}(3)\,\mathrm{survivorCount}(5)\,\mathrm{survivorCount}(7)\,\mathrm{survivorCount}(11).
> \]
> Moreover compute `survivorCount 11` exactly.

This is not just another modulus computation. It is the first test of whether the observed behavior at `3,5,7` persists at a genuinely new prime.

### Lean 4 type signature target

```lean
theorem survivorCount_1155 :
    survivorCount 1155 =
      survivorCount 3 * survivorCount 5 * survivorCount 7 * survivorCount 11 := ...

#eval survivorCount 11
#eval survivorCount 1155
```

If computation is expensive, prove the factorization theorem abstractly and evaluate only `survivorCount 11`.

### Proof strategy steps

#### Strategy A: Abstract theorem first, computation second
1. Prove `survivorCount_mul_of_coprime`.
2. Use associativity and pairwise coprimeness of `3,5,7,11`.
3. Reduce `survivorCount 1155` to `survivorCount 11` and previously certified values.

This is the best route because it turns a computation into a corollary of theory.

#### Strategy B: Certified brute-force at prime 11
1. Enumerate all triples in `(ZMod 11)^3`.
2. Decide the four square conditions by finite search.
3. Prove the resulting count by `native_decide` or a reflected computation lemma.
4. Combine with CRT multiplicativity.

This gives a robust computational certificate.

#### Strategy C: Use quadratic residue structure of `𝔽₁₁`
1. Exploit the exact square set in `ZMod 11`.
2. Reduce each diagonal condition to membership in a small finite set.
3. Organize the count by orbit symmetries under coordinate permutations and sign changes.

This may give conceptual insight into why the local factor has its specific size.

### Why this matters

If prime `11` behaves multiplicatively, the program becomes scalable: each new prime contributes an independent local factor. If not, then you have discovered a deep correlation phenomenon, which is arguably even more interesting. Either outcome is publishable-quality mathematics when formalized cleanly.

---

## Breakthrough Objective 3: Density-zero theorem along squarefree primorial moduli

### Precise theorem target

Conditional on enough local shrinkage, prove a theorem of the form:

> **Theorem (density product formula).**  
> For squarefree `N = ∏_{p∈S} p`,
> \[
> \frac{\mathrm{survivorCount}(N)}{N^3}
> = \prod_{p\in S} \frac{\mathrm{survivorCount}(p)}{p^3}.
> \]
> Consequently, if there exists an infinite set of primes `P` such that
> \[
> \frac{\mathrm{survivorCount}(p)}{p^3} \le 1-\delta
> \quad\text{for all } p\in P
> \]
> for some fixed `δ > 0`, then the survivor density tends to `0` along the corresponding squarefree products.

This is the first theorem in the direction of a genuine impossibility heuristic.

### Lean 4 type signature target

A finite-product version is realistic now:

```lean
theorem survivorDensity_prod_primes
    (s : Finset ℕ)
    (hprime : ∀ p ∈ s, Nat.Prime p)
    (hpairwise : s.Pairwise Nat.Coprime) :
    survivorCount (∏ p in s, p) =
      ∏ p in s, survivorCount p := ...
```

and then

```lean
theorem survivorDensity_ratio_prod_primes
    (s : Finset ℕ)
    (hprime : ∀ p ∈ s, Nat.Prime p)
    (hpairwise : s.Pairwise Nat.Coprime) :
    (survivorCount (∏ p in s, p) : ℚ) / (∏ p in s, p : ℚ)^3 =
      ∏ p in s, ((survivorCount p : ℚ) / (p : ℚ)^3) := ...
```

### Proof strategy steps

#### Strategy A: Finset induction on primes
1. Prove the multiplicative theorem for two coprime moduli.
2. Induct over a `Finset` of pairwise coprime primes.
3. Convert multiplicativity of counts into multiplicativity of densities.

#### Strategy B: Monoid-hom viewpoint
1. Show `survivorCount` restricted to squarefree moduli defines a multiplicative arithmetic function.
2. Package density as another multiplicative function.
3. Derive product formulas abstractly.

This is cleaner if you want to build a reusable arithmetic-function framework.

### Revolutionary significance

This would connect the perfect cuboid problem to:
- **arithmetic statistics** via local density products,
- **Selmer-sieve philosophy** via survival probabilities,
- **probabilistic number theory** via geometric decay of admissible classes.

In other words: stop treating perfect cuboids as a Diophantine curiosity, and start treating them as an object with a local statistical mechanics.

---

## Breakthrough Objective 4: Elliptic fibration of the doubly constrained surface

The modular sieve is the local side. The geometric side is the constrained rational surface.

### Precise theorem target

Starting from
\[
u^2 - 1 = a^2,\qquad v^2 - 1 = b^2,\qquad w^2 = u^2 + v^2 - 1,
\]
use the standard rational parametrizations
\[
u = \frac{r^2+1}{2r},\qquad v = \frac{s^2+1}{2s}.
\]
Substituting gives
\[
w^2
= \frac{(r^2+1)^2}{4r^2} + \frac{(s^2+1)^2}{4s^2} - 1.
\]
After clearing denominators:
\[
(2rsw)^2 = r^4s^2 + r^2s^4 - 2r^2s^2 + r^2 + s^2.
\]

The target is:

> **Conjectural theorem.**  
> For fixed rational `r ≠ 0`, the affine curve in variables `(s,W)` defined by
> \[
> W^2 = r^2 s^4 + (r^4 - 2r^2 + 1)s^2 + r^2
> \]
> is a genus-1 curve over `ℚ(r)` for generic `r`, birational to an elliptic curve.

Here `W = 2rsw`.

This is the geometric heart of the program. If true, the perfect cuboid problem is probing rational points on an elliptic surface, not an amorphous quartic accident.

### Lean formalization target

A full algebraic-geometry formalization may be too ambitious immediately, but you can formalize the algebraic reduction:

```lean
theorem cuboid_parametrized_quartic
    {r s w : ℚ}
    (hr : r ≠ 0) (hs : s ≠ 0)
    (hu : ((r^2 + 1) / (2*r))^2 - 1 = ((r^2 - 1) / (2*r))^2)
    (hv : ((s^2 + 1) / (2*s))^2 - 1 = ((s^2 - 1) / (2*s))^2) :
    w^2 = ((r^2 + 1) / (2*r))^2 + ((s^2 + 1) / (2*s))^2 - 1 →
    (2*r*s*w)^2 = r^2*s^4 + (r^4 - 2*r^2 + 1)*s^2 + r^2 := ...
```

Then isolate the quartic:

```lean
def quarticFiber (r : ℚ) (s W : ℚ) : Prop :=
  W^2 = r^2*s^4 + (r^4 - 2*r^2 + 1)*s^2 + r^2
```

### Proof strategy options

#### Strategy A: Pure algebraic elimination
1. Substitute the parametrizations directly.
2. Clear denominators carefully under `r,s ≠ 0`.
3. Simplify to the quartic fiber equation.
4. Compute discriminant conditions showing generic smoothness.

This is the immediate formal target.

#### Strategy B: Symmetric-variable reduction
1. Notice the quartic is even in `s`, so set `t = s^2`.
2. View the equation as a double cover of the `t`-line:
   \[
   W^2 = r^2 t^2 + (r^2-1)^2 t + r^2.
   \]
3. Analyze branch points and generic nonsingularity.
4. Recover genus-1 structure from the quartic double cover.

This is the most conceptually illuminating route.

#### Strategy C: Birational conversion to Weierstrass form
1. Find a rational point or section at infinity.
2. Apply standard quartic-to-cubic transformation.
3. Produce a Weierstrass equation over `ℚ(r)`.
4. Study rank or torsion experimentally.

This is the route that could turn the cuboid problem into an elliptic-surface problem in earnest.

### Why this would be a breakthrough

Because it would link the perfect cuboid problem to:
- **elliptic surfaces**,
- **rational point obstructions**,
- **descent and Mordell–Weil computations**,
- and potentially **Brauer–Manin-style explanations** for nonexistence.

That is a field-opening reframing. The cuboid problem would stop being “a hard system of three Pythagorean constraints” and become “an arithmetic surface with local and global obstructions.”

---

## Cross-domain connections you should exploit

1. **Arithmetic statistics / Euler products**  
   The modular survivor density behaves like a local factor in a singular series. Formalize this analogy explicitly.

2. **Constraint satisfaction and coding theory**  
   The residue sieve defines a highly sparse admissibility code in `(Z/nZ)^3`. Think of primes as independent channels and survivor classes as codewords surviving parity-like checks.

3. **Statistical mechanics**  
   Each prime contributes a local energy penalty `-log(count(p)/p^3)`. The density-zero question becomes a partition-function collapse.

4. **Elliptic and K3 surface philosophy**  
   If the constrained surface fibers in genus 1, local sieve data may be interpreted as local point counts on fibers, suggesting a bridge to arithmetic geometry.

5. **Formal methods / certified computation**  
   A theorem proving that search reduction factors are mathematically certified, not heuristic, is itself a new style of number theory: **proof-producing arithmetic experimentation**.

---

## Application keywords

perfect cuboid, modular sieve, CRT multiplicativity, local-global principle, Euler product, arithmetic statistics, quadratic residues, certified search reduction, finite field geometry, elliptic fibration, rational points, Diophantine obstruction, formalized number theory, Lean 4, Mathlib

---

## Concrete deliverables

1. Prove `survivorCount_mul_of_coprime`.
2. Compute and certify `survivorCount 11`.
3. Derive the `1155` factorization theorem.
4. Formalize the quartic-fiber equation from the double parametrization.
5. If feasible, prove a generic smoothness lemma for the quartic fiber.

---

## FUTURE_DIRECTIONS.md requirement

Produce a structured `FUTURE_DIRECTIONS.md` with **3–5 falsifiable scientific hypotheses**, each with:
- a precise conjecture,
- a concrete Lean-testable or computation-testable criterion,
- and a statement of what mathematical conclusion follows if true or false.

At minimum include hypotheses of the following form:

1. **Prime-uniform shrinkage hypothesis**  
   There exists `δ > 0` and infinitely many primes `p` such that  
   `survivorCount p ≤ (1 - δ) * p^3`.  
   **Test:** certify counts for primes up to a substantial bound.  
   **If true:** density tends to zero along suitable squarefree products.  
   **If false:** the sieve may have unexpectedly large local windows.

2. **Quartic-fiber generic genus-1 hypothesis**  
   For all but finitely many rational `r ≠ 0`, the quartic fiber is smooth and genus `1`.  
   **Test:** compute discriminant and identify exceptional parameters.  
   **If true:** the cuboid surface admits an elliptic-fibration model.  
   **If false:** the geometry may instead be rational or singular in a structured way.

3. **Local-to-global obstruction hypothesis**  
   There exists a finite modulus `N` with `survivorCount N = 0`.  
   **Test:** compute multiplicative local factors across more primes.  
   **If true:** perfect cuboids are impossible by a finite modular obstruction.  
   **If false:** the obstruction is subtler and likely global-geometric.

4. **Bias in local factors hypothesis**  
   The average of `survivorCount p / p^3` over primes tends to a limit strictly below `1`.  
   **Test:** compute empirical averages over primes and compare against random-model predictions.  
   **If true:** strong evidence for a robust Euler-product collapse.  
   **If false:** local admissibility may fluctuate too much for naive density heuristics.

5. **Elliptic rank obstruction hypothesis**  
   The induced elliptic fibers have generically rank `0` or only torsion sections compatible with trivial cuboids.  
   **Test:** convert sample fibers to Weierstrass form and compute rational points.  
   **If true:** nonexistence may follow from Mordell–Weil rigidity.  
   **If false:** rational families may exist and the obstruction must lie elsewhere.

Be bold: either uncover a multiplicative obstruction theory for perfect cuboids, or force the problem into the arithmetic geometry of elliptic surfaces. Either outcome changes the conversation.

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
