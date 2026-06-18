# Future Directions — LWE Hardness Reduction

The file `HardnessReduction.lean` formalizes the *geometric core* of the
worst-case-to-average-case reduction for Learning with Errors: bounded-distance
decoding (BDD) is unique inside half the first minimum `λ₁/2`, the same radius
that gives the lattice packing, and the quantitative parameter chain
`α·q ≥ 2√n` that ties the average-case noise rate `α` to the worst-case
`GapSVP` approximation factor `γ`. It builds on the algebraic search-to-decision
material in `SearchDecisionCore.lean` (the affine-rerandomization equivalences
`ZMod.affine_bijective` and the pigeonhole `search_to_decision_advantage_bound`).
Below are five concrete, falsifiable directions that extend this skeleton toward
a complete machine-checked reduction.

## 1. Minkowski's first theorem as an effective lower bound on `λ₁`

Every theorem in the current file is stated relative to an *abstract* lower
bound `lam ≤ λ₁`. The natural next step is to discharge that hypothesis for
genuine full-rank lattices by proving Minkowski's first theorem in the form
`λ₁(L) ≤ √n · covol(L)^{1/n}`, and dually a packing lower bound on `λ₁` from
the determinant. Mathlib already provides `ZLattice.covolume` and the
convex-body Minkowski theorem (`MeasureTheory.exists_ne_zero_mem_lattice...`),
so the missing piece is the explicit `√n` constant.
**The key insight is** that the abstract `hlam` hypothesis used everywhere in
`HardnessReduction.lean` is exactly the conclusion of Minkowski's theorem, so
proving the latter instantly upgrades all BDD/packing theorems from conditional
to unconditional for the `q`-ary lattice. **Why now?** The covolume API and the
measure-theoretic Minkowski lemma landed in recent Mathlib, so the constant is
the only genuinely new analytic estimate required — a self-contained, testable
target.

## 2. Discrete-Gaussian tail bound ⇒ explicit decoding radius

The current `lwe_decoding_correct` assumes a hard norm bound `‖e‖ < λ₁/2`. Real
LWE errors are discrete Gaussians, so the falsifiable conjecture is a Banaszczyk
tail bound: for parameter `σ`, `Pr[‖e‖ ≥ σ√n] ≤ 2^{-n}`, hence decoding
succeeds except with exponentially small probability whenever `σ√n < λ₁/2`.
**The key insight is** that the deterministic uniqueness theorem and a single
scalar tail inequality factor cleanly: uniqueness needs no probability, and the
probability lives entirely in one `Pr[‖e‖ ≥ r]` bound that can be proved
independently and then composed. **Why now?** Mathlib's `ProbabilityTheory` and
`MeasureTheory.Gaussian` machinery is mature enough to state sub-Gaussian
concentration; pairing it with the already-proven uniqueness lemma is the first
end-to-end *probabilistic* correctness statement for LWE in Lean.

## 3. List-decoding beyond `λ₁/2`: a finite-ambiguity theorem

`lattice_packing_disjoint` shows that below `λ₁/2` there is at most one solution.
The conjecture is a quantitative relaxation: within radius `r = c·λ₁` for
`c < 1`, the number of lattice points near any target is bounded by a function
of `c` and the dimension `n` (a volumetric packing argument). This is the
lattice analogue of the Johnson bound in coding theory.
**The key insight is** that disjointness of `λ₁/2`-balls already gives a packing
of the radius-`r` neighborhood, so counting solutions reduces to a
volume-ratio estimate `(1 + 2c)^n` rather than any new algebra. **Why now?**
With `lattice_packing_disjoint` in hand the combinatorial half is done; only the
ambient-volume comparison (available via `MeasureTheory.volume` of balls)
remains, making this an incremental but genuinely new result.

## 4. The full search-to-decision pipeline over `ZMod q`

`SearchDecisionCore.lean` supplies the affine rerandomization and the
per-coordinate pigeonhole; `HardnessReduction.lean` supplies the BDD uniqueness.
The conjecture is that these compose into a fully formal search-to-decision
theorem: a decision distinguisher with advantage `ε` yields, coordinate by
coordinate over `ZMod q` (prime `q`), recovery of the secret with advantage
`≥ ε/n`. **The key insight is** that `ZMod.affine_bijective` guarantees a wrong
secret guess produces a *uniform* sample, so each hybrid step is exactly one
application of the existing affine equivalence plus one pigeonhole step — no new
mathematics, only careful bookkeeping of the hybrid distributions.
**Why now?** Both halves already exist and compile in this project; the
remaining work is a definitional model of "advantage" that both files can share,
which is precisely the kind of cross-file synthesis this catalog rewards.

## 5. Modulus switching with a verified noise budget

`modulus_for_approx_factor` and `noise_rate_for_decoding` pin down the
`α·q ≥ 2√n` constraint; `SearchDecisionCore.combined_noise_after_switching`
bounds the post-switch noise by `B + nδ`. The conjecture is a *composed* budget
theorem: switching from modulus `q` to `q' < q` preserves decryption
correctness iff `B·(q'/q) + n·δ < q'/4`, giving the precise condition under
which the smaller modulus still lands inside the BDD radius of Section 1.
**The key insight is** that modulus switching is a scaling of the same lattice,
so the rounding-error accumulation lemma and the `λ₁/2` uniqueness theorem can
be glued by tracking a single inequality on the scaled radius. **Why now?**
The noise-accumulation bounds are already proven in the sibling file, so this
direction tests whether the two modules can be unified into one quantitative
correctness statement — the natural capstone of the LWE-decoding theory.
