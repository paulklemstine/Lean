## Assignment: Tropical Noether Shadow for Piecewise-Linear Mechanics

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important.

2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.

3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog. Check the catalog references to confirm novelty.

4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain (e.g., number theory + tropical geometry, algebra + physics).

5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test that could disprove it.

---

### Research Direction

**Conjecture (Tropical Noether Shadow):** For piecewise-linear (max-plus tropicalized) Lagrangians on ℝⁿ, every translation symmetry induces a piecewise-constant tropical energy along minimizing trajectories. Jumps occur only at breakpoints where the active affine piece changes, and at each breakpoint the pre- and post-jump charges satisfy a **tropical balance equation** — the min-plus analogue of the classical Noether conserved quantity $Q = \sum_i \frac{\partial L}{\partial \dot{q}_i}\xi_i$.

This is not merely an analogy. The tropical balance equation at breakpoints is structurally identical to the **balancing condition for tropical curves** in tropical Hodge theory and to **Kirchhoff's current law** in electrical networks. This triple correspondence — tropical Noether balance ↔ tropical curve balancing ↔ Kirchhoff — opens a new bridge between variational mechanics, algebraic geometry, and network theory.

**Test:**
1. Generate 1000 random piecewise-linear Lagrangians on ℝ² with explicit translation symmetry in one coordinate (all $a_i$ satisfying $a_i \cdot \xi = 0$).
2. Compute tropical-minimizing discrete trajectories via shortest-path algorithms on the tropical action graph.
3. Evaluate the proposed tropical Noether charge $Q_{\text{trop}}(t) = b_{j^*(t)} \cdot \xi$ at each step.
4. Verify: (a) the charge is piecewise-constant, (b) jumps occur only at breakpoints, (c) the charge values satisfy the tropical balance equation $b_{j^-}^T \xi \oplus b_{j^+}^T \xi = \min(b_{j^-}^T \xi, b_{j^+}^T \xi)$ at each transition, which reduces to equality when the transition is non-degenerate.

**Impact:** Establishes tropical mechanics as a rigorous subdomain of formal physics. Creates a pipeline: tropical mechanics → tropical Hodge theory → combinatorial optimization. The tropical balance equation at breakpoints is the same algebraic structure that governs tropical curve vertices and electrical network junctions, suggesting a unified "tropical conservation principle" spanning all three domains.

**Catalog References:**
- `tropical_vacuum_energy_eq_minimal_action` (FINAL/Physics/TropicalVacuumEnergy.lean)
- `energy_conserved` (Physics/NoetherTheorems.lean)
- Various tropical semiring theorems in catalog

**Lineage:** Extends `energy_conserved` + `tropical_vacuum_energy_eq_minimal_action`

**Ambition:** 🔴 Grand challenge — tropical mechanics is largely unexplored formally

---

### Precise Theorem Targets

**Definition 1 — TropicalLagrangian.** A tropical Lagrangian is a max-plus concave piecewise-linear function $L: \mathbb{R}^n \times \mathbb{R}^n \to \mathbb{R}$ represented as a finite max of affine pieces:

$$L(q, v) = \max_{i \in I} \left(\langle a_i, q \rangle + \langle b_i, v \rangle + c_i\right)$$

```lean
structure TropicalLagrangian (n : ℕ) where
  numPieces : ℕ
  a : Fin numPieces → (Fin n → ℝ)  -- position coefficient vectors
  b : Fin numPieces → (Fin n → ℝ)  -- velocity coefficient vectors
  c : Fin numPieces → ℝ            -- constant offsets
  hnum : 0 < numPieces

def TropicalLagrangian.eval {n : ℕ} (L : TropicalLagrangian n)
    (q v : Fin n → ℝ) : ℝ :=
  (Finset.univ.image (fun i : Fin L.numPieces =>
    ∑ j, L.a i j * q j + ∑ j, L.b i j * v j + L.c i)).max'
    (by simp [Finset.image_nonempty]; exact ⟨0, L.hnum⟩⟩)
```

**Definition 2 — TropicalSymmetry.** A translation symmetry $\xi$ for a tropical Lagrangian $L$ requires that every affine piece is invariant under $q \mapsto q + \epsilon\xi$:

```lean
def HasTranslationSymmetry {n : ℕ} (L : TropicalLagrangian n) (ξ : Fin n → ℝ) : Prop :=
  ∀ i : Fin L.numPieces, ∀ ε : ℝ, ∀ q v : Fin n → ℝ,
    ∑ j, L.a i j * (q j + ε * ξ j) + ∑ j, L.b i j * v j + L.c i =
    ∑ j, L.a i j * q j + ∑ j, L.b i j * v j + L.c i
-- Equivalent to: ∀ i, ⟨L.a i, ξ⟩ = 0
```

**Definition 3 — TropicalNoetherCharge.** The tropical Noether charge at a point $(q,v)$ is the inner product of the active piece's velocity coefficient with the symmetry direction:

```lean
def TropicalNoetherCharge {n : ℕ} (L : TropicalLagrangian n)
    (ξ : Fin n → ℝ) (q v : Fin n → ℝ) : ℝ :=
  ⟨L.b (L.activePiece q v), ξ⟩
  -- where activePiece returns the argmax index
```

**Definition 4 — TropicalTrajectory and TropicalAction.** A discrete tropical trajectory is a sequence of positions, and the tropical action is the max-plus "integral" (maximum of the Lagrangian evaluated along the path):

```lean
structure TropicalTrajectory (n : ℕ) where
  length : ℕ
  positions : Fin (length + 1) → (Fin n → ℝ)
  hlength : 0 < length

def TropicalTrajectory.velocities {n : ℕ} (γ : TropicalTrajectory n)
    (t : Fin γ.length) : Fin n → ℝ :=
  fun j => γ.positions (t + 1) j - γ.positions t j

def tropicalAction {n : ℕ} (L : TropicalLagrangian n)
    (γ : TropicalTrajectory n) : ℝ :=
  (Finset.univ.image (fun t : Fin γ.length =>
    L.eval (γ.positions t) (γ.velocities t))).max' ...
```

**Definition 5 — Breakpoint and TropicalBalance.** A breakpoint is a time step where the active piece changes. The tropical balance equation requires that at each breakpoint, the outgoing charge equals the incoming charge in the tropical semiring:

```lean
def IsBreakpoint {n : ℕ} (L : TropicalLagrangian n)
    (γ : TropicalTrajectory n) (t : Fin γ.length) : Prop :=
  L.activePiece (γ.positions t) (γ.velocities t) ≠
  L.activePiece (γ.positions (t+1)) (γ.velocities (t+1))

-- The tropical balance condition at a breakpoint
def TropicalBalanceAt {n : ℕ} (L : TropicalLagrangian n)
    (ξ : Fin n → ℝ) (γ : TropicalTrajectory n) (t : Fin γ.length) : Prop :=
  TropicalNoetherCharge L ξ (γ.positions t) (γ.velocities t) =
  TropicalNoetherCharge L ξ (γ.positions (t+1)) (γ.velocities (t+1))
```

---

### Theorem Targets (at least 3 with deep proofs)

**Theorem 1 — `tropical_noether_charge_piecewise_constant`:** The foundational conservation law. If a tropical Lagrangian has translation symmetry $\xi$, then along any tropical-minimizing trajectory, the tropical Noether charge is piecewise-constant: it can only change at breakpoints.

```lean
theorem tropical_noether_charge_piecewise_constant {n : ℕ}
    (L : TropicalLagrangian n) (ξ : Fin n → ℝ)
    (hSymm : HasTranslationSymmetry L ξ)
    (γ : TropicalTrajectory n)
    (hMin : IsTropicalMinimizer L γ)
    {t : Fin γ.length}
    (hNotBreak : ¬ IsBreakpoint L γ t) :
    TropicalNoetherCharge L ξ (γ.positions t) (γ.velocities t) =
    TropicalNoetherCharge L ξ (γ.positions (t+1)) (γ.velocities (t+1)) := by
  sorry
```

**Theorem 2 — `tropical_balance_at_breakpoints`:** The bridge to tropical Hodge theory. At every breakpoint of a tropical-minimizing trajectory under translation symmetry, the tropical Noether charge satisfies the balance equation (continuity of charge, not just piecewise-constancy — this is the deep result):

```lean
theorem tropical_balance_at_breakpoints {n : ℕ}
    (L : TropicalLagrangian n) (ξ : Fin n → ℝ)
    (hSymm : HasTranslationSymmetry L ξ)
    (γ : TropicalTrajectory n)
    (hMin : IsTropicalMinimizer L γ)
    (t : Fin γ.length)
    (hBreak : IsBreakpoint L γ t) :
    TropicalNoetherCharge L ξ (γ.positions t) (γ.velocities t) =
    TropicalNoetherCharge L ξ (γ.positions (t+1)) (γ.velocities (t+1)) := by
  sorry
```

**Theorem 3 — `tropical_noether_charge_global_constant` (the capstone):** Combining Theorems 1 and 2: the tropical Noether charge is globally constant along any tropical-minimizing trajectory. This is the full tropical Noether theorem — piecewise-constancy + balance at breakpoints = full constancy.

```lean
theorem tropical_noether_charge_global_constant {n : ℕ}
    (L : TropicalLagrangian n) (ξ : Fin n → ℝ)
    (hSymm : HasTranslationSymmetry L ξ)
    (γ : TropicalTrajectory n)
    (hMin : IsTropicalMinimizer L γ)
    (t s : Fin γ.length) :
    TropicalNoetherCharge L ξ (γ.positions t) (γ.velocities t) =
    TropicalNoetherCharge L ξ (γ.positions s) (γ.velocities s) := by
  sorry
```

**Theorem 4 — `tropical_balance_equiv_kirchhoff` (cross-domain bridge):** The tropical balance equation at a breakpoint of a 1-dimensional tropical trajectory is equivalent to Kirchhoff's current law at a node of the corresponding resistive network. This connects tropical mechanics to network theory.

```lean
-- A tropical breakpoint induces a resistive network node
-- where the "currents" (subdifferential slopes) satisfy KCL
theorem tropical_balance_equiv_kirchhoff {n : ℕ}
    (L : TropicalLagrangian n) (ξ : Fin n → ℝ)
    (hSymm : HasTranslationSymmetry L ξ)
    (γ : TropicalTrajectory n)
    (hMin : IsTropicalMinimizer L γ)
    (t : Fin γ.length)
    (hBreak : IsBreakpoint L γ t) :
    -- The tropical balance condition equals the Kirchhoff condition
    -- for the induced network at the breakpoint
    TropicalBalanceCondition L γ t ↔
    KirchhoffCurrentLaw (toResistiveNetwork L γ t) := by
  sorry
```

---

### Proof Strategies

**Strategy A: Active-Piece Decomposition (Most Promising).**

Between breakpoints, the active piece $j^*$ is constant, so the tropical Lagrangian reduces to a single affine function $L(q,v) = \langle a_{j^*}, q\rangle + \langle b_{j^*}, v\rangle + c_{j^*}$. For affine Lagrangians, the Euler-Lagrange equations give $\dot{p} = a_{j^*}$ where $p = b_{j^*}$ is constant. Translation symmetry ($\langle a_{j^*}, \xi\rangle = 0$) then directly implies $Q = \langle b_{j^*}, \xi\rangle$ is constant on each segment. At breakpoints, the minimizing condition forces the charge to be continuous (if it jumped, you could modify the trajectory to lower the tropical action). This is the most promising strategy because it reduces to classical mechanics on each segment and uses the optimality condition only at breakpoints.

*Proof architecture for Theorem 1:* (1) Show that on a non-breakpoint segment, `activePiece` is constant by definition of breakpoint. (2) Unfold `TropicalNoetherCharge` to get `⟨L.b j*, ξ⟩` on both sides with the same `j*`. (3) Apply `congr_arg` or direct computation. (4) The translation symmetry hypothesis `hSymm` ensures `⟨L.a i, ξ⟩ = 0` for all pieces, which is needed for the Euler-Lagrange step in the breakpoint argument.

*Proof architecture for Theorem 2:* (1) At a breakpoint, two pieces $j^-$ and $j^+$ are both active (achieve the maximum). (2) The minimality condition `hMin` implies that switching from $j^-$ to $j^+$ doesn't decrease the Lagrangian value. (3) Combined with translation symmetry, this forces $\langle b_{j^-}, \xi\rangle = \langle b_{j^+}, \xi\rangle$. (4) This is the tropical balance equation, and it is structurally identical to the balancing condition for tropical curves.

**Strategy B: Tropical Variational Calculus.**

Develop tropical Euler-Lagrange equations directly. For a max-plus Lagrangian, the subdifferential $\partial_v L$ is set-valued (it's the convex hull of the $b_i$ for active pieces). The tropical Euler-Lagrange equation is: $\dot{p} \in \partial_q L$ where $p \in \partial_v L$. Translation symmetry means $0 \in \partial_q L$ along the $\xi$ direction, so $d/dt(p \cdot \xi) = 0$, giving constancy of $p \cdot \xi$ in a tropical sense. This approach is more general but requires developing the theory of tropical subdifferentials, which is substantial new infrastructure.

**Strategy C: Graph-Theoretic / Shortest-Path Reduction.**

Represent the tropical minimization problem as a shortest-path problem on a graph whose nodes are (position, active-piece) pairs and whose edges are transitions. The tropical Noether charge is a potential function on this graph. Conservation of charge corresponds to the fact that shortest paths have monotone (in a tropical sense) potential. This connects to the theory of potential-reducing paths in network flow. Less promising for proving the specific theorems, but provides the computational framework for the test.

*Recommendation:* Use Strategy A for the main theorems (it's the most direct and builds on classical mechanics intuitions). Use Strategy C for the computational implementation and the cross-domain connection to Kirchhoff's laws (Theorem 4).

---

### Novel Definitions (not in catalog)

1. **`TropicalLagrangian`** — Piecewise-linear Lagrangian as max of affine pieces. Not in catalog.
2. **`TropicalNoetherCharge`** — The min-plus conserved quantity $\langle b_{j^*}, \xi\rangle$. Not in catalog.
3. **`TropicalBalanceCondition`** — The equality of charge across breakpoints, structurally identical to tropical curve balancing. Not in catalog.
4. **`IsTropicalMinimizer`** — Trajectory minimizing the tropical action (max of Lagrangian values). Not in catalog.
5. **`toResistiveNetwork`** — Functor from tropical mechanical breakpoints to resistive network nodes. Not in catalog.

---

### Conjecture with Testable Prediction

**Conjecture (Tropical Noether Universality):** For any tropical Lagrangian with translation symmetry $\xi$, the tropical Noether charge $Q_{\text{trop}}$ is globally constant along minimizing trajectories — not merely piecewise-constant. The balance equation at breakpoints forces continuity.

*Falsifiable test:* Generate 1000 random tropical Lagrangians on ℝ³ with 5-20 pieces each, random translation symmetries, and compute minimizing trajectories. Check whether $Q_{\text{trop}}$ is exactly constant (within floating-point tolerance) at every step. A single counterexample where $Q_{\text{trop}}$ jumps at a breakpoint would falsify the conjecture.

*If falsified:* The fallback theorem is `tropical_noether_charge_piecewise_constant` (Theorem 1 alone), which only requires piecewise-constancy without the balance condition.

---

### Required Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3-5 testable scientific hypotheses:
   1. *Tropical Noether for rotational symmetry:* Rotation symmetries induce tropical angular momentum conservation. Test: construct tropical Lagrangians with SO(2) symmetry and verify piecewise-constancy of tropical angular momentum.
   2. *Tropical Hodge correspondence:* The tropical balance equation at mechanical breakpoints is equivalent to the balancing condition for tropical curves under an appropriate duality functor. Test: compute both sides for 100 examples and verify equality.
   3. *Quantum tunneling through tropical breakpoints:* At breakpoints, the classical trajectory is non-differentiable; tropical "quantum" corrections smooth the kink. Test: define a tropical path integral and compute corrections near breakpoints.
   4. *Tropical Noether and tropical mutual information:* The conserved tropical charge bounds the tropical mutual information of the trajectory distribution. Test: compute both for random tropical Lagrangians and check the inequality.
   5. *Network flow optimization via tropical mechanics:* Tropical-minimizing trajectories solve a min-max optimization problem dual to a network flow problem. Test: benchmark tropical mechanics solvers against network flow solvers on equivalent instances.

(b) **RESEARCH_PAPER.md** — A standalone scientific document presenting: (1) the Tropical Noether Shadow theorem, (2) the tropical balance equation and its equivalence to Kirchhoff's law, (3) computational verification, (4) the connection to tropical Hodge theory. Someone reading ONLY this paper must understand what was discovered, why it matters, and what to investigate next.

(c) **ARTICLE.md** — Scientific American style: "The Tropical Shadow of Noether's Theorem: How piecewise-linear physics reveals hidden conservation laws at the breakpoints of reality." Engaging, accessible, explaining the discovery to a broad audience.

(d) **Verified algorithm:** A certified algorithm that, given a tropical Lagrangian and symmetry, computes the tropical Noether charge along a trajectory and verifies its constancy. This should be a Lean function with a correctness proof, not just a theorem statement.

(e) **demo.py** — Interactive demonstration that: (1) generates random tropical Lagrangians with translation symmetry, (2) computes minimizing trajectories via shortest-path on the tropical action graph, (3) evaluates the tropical Noether charge at each step, (4) plots the charge over time showing piecewise-constancy, (5) highlights breakpoints and verifies the balance equation.

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
