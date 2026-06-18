
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are leading a research team: Hypothesizer, Experimenter, Analyst,
Critic, and Synthesist. Run the loop:
Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate.
Your ONLY job is to produce **new Lean 4 code** and **take good notes**
for the next team.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by theorem declarations)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.
5. **Lab Notebook** as `-- !-- Lab Notebook -- !--` comment blocks
   in each .lean file: Hypothesis, Result, Insight, Failure analysis.

            ### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
            - NO `ARTICLE.md`
            - NO `RESEARCH_PAPER.md`
            - NO `demo.py` / `algorithms.py`
            - NO HTML widgets
            - NO `PACKAGE.json`
            - NO prose for human readers (except FUTURE_DIRECTIONS.md)

            ### WHY THIS NARROW:
            The Lean 4 file IS the deliverable. A self-contained Lean file with
            3-5 world-class theorems is worth more than 30K characters of prose
            about trivial results. Focus 100% of your compute on the math.
            If your work is genuinely world-class, the packaging step is dispatched
            automatically and cheaply.

            ### CATALOG SYNTHESIS (required — read the catalog context below):
            The Catalog Context and Recent Discoveries sections list existing theorems
            already proven in this project. You MUST analyze these and combine concepts
            from the catalog with the research direction above. Specifically:

            1. **Identify relevant catalog theorems** — Which existing results connect
               to your research direction? Cite them by name in your proof sketches.
            2. **Build on catalog foundations** — Your theorems should EXTEND or
               GENERALIZE catalog results, not reprove them from scratch. Use `import`
               and reference existing definitions and lemmas where possible.
            3. **Combine concepts across domains** — The most valuable theorems connect
               ideas from different catalog domains (e.g., applying algebraic structures
               to topological problems, or using combinatorial arguments in number theory).
               Look for cross-domain connections in the catalog context.
            4. **Avoid duplication** — Check the catalog context before proving. If a
               similar result already exists, extend it rather than reproving it.


## Concept

**Title**: Linear Merkle–Damgård collision-resistance theory
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Merkle Tree Hashing and Collision Resistance

This cycle extended the linear Merkle–Damgård collision-resistance theory
(`Cryptography.MerkleDamgard`: `merkleDamgard`, `foldl_joint_injective`,
`compress_injective_md_injective`, `md_collision_implies_compress_collision`)
to *binary hash trees* in `Cryptography.MerkleTreeHash`. The new file proves:

- `treeHash_inj_sameShape` — injectivity of the tree hash on same-shape trees;
- `tree_collision_implies_compression_collision` — the security reduction
  (a tree collision yields a leaf-map or compression collision);
- `treeHash_inj_domainSeparated` — full cross-shape injectivity once leaf- and
  node-hashes are domain-separated;
- `treeHash_leftComb_eq_merkleDamgard` — the bridge identifying Merkle–Damgård
  as the left-comb (linear) special case of tree hashing;
- `tree_cross_shape_collision_exists` — a boundary counterexample showing the
  same-shape / domain-separation hypotheses are necessary.

The directions below are concrete, falsifiable next steps.

## Direction 1: Quantitative multi-collision bounds for shaped trees

Conjecture: For a compression `h : α → α → α` with at most `c` collision pairs,
the number of distinct trees of a *fixed* shape `S` with `n` leaves that share a
common root hash is bounded by a polynomial `P_S(c, n)` whose degree equals the
number of internal nodes of `S`, and this bound is tight for "balanced" shapes.

The key insight is that a fixed shape turns the hash into a *layered* composition
of `h`, so multi-collisions factor through per-node collision multiplicities; the
shape's internal-node count controls how these multiplicities multiply. This
upgrades the qualitative reduction `tree_collision_implies_compression_collision`
to a counting statement, the tree analogue of Joux multicollisions for
Merkle–Damgård.

Why now? We already have `treeHash_inj_sameShape`, which is exactly the `c = 0`
base case; the inductive skeleton of its proof (peel one `h`-layer, recurse on
both subtrees) is the natural carrier for a multiplicity-counting induction.

## Direction 2: Length/shape-tagging realizes domain separation generically

Conjecture: For any injective `g` and injective `h`, the *tagged* tree hash
`treeHash (Sum.inl ∘ g) h'` — where `h'` writes node outputs into a disjoint tag
class — automatically satisfies the `hsep` hypothesis of
`treeHash_inj_domainSeparated`, hence is fully (cross-shape) collision resistant
with *no* extra assumption beyond injectivity of `g` and `h`.

The key insight is that the abstract obstruction in
`tree_cross_shape_collision_exists` is precisely the *overlap* between the range
of `g` and the range of `h`; a one-bit tag forces these ranges disjoint, so
domain separation is not an extra hypothesis but a free encoding transformation.

Why now? `treeHash_inj_domainSeparated` isolates `hsep` as the single missing
ingredient, and `tree_cross_shape_collision_exists` pinpoints range-overlap as
the only failure mode — so the conjecture is a constructive closing of exactly
that gap.

## Direction 3: Sponge / unbalanced-tree hashing unifies with the comb bridge

Conjecture: The bridge `treeHash_leftComb_eq_merkleDamgard` generalizes to an
equivalence between *any* binary-tree hashing schedule and an iterated
"absorb/squeeze" sponge over a 2-to-1 permutation, with collision resistance of
one transferring to the other up to the shape's depth.

The key insight is that `leftCombAux` is literally a `foldl`, i.e. a degenerate
sponge with capacity zero; replacing the comb's right spine of leaves by an
arbitrary tree schedule is the same as choosing a non-trivial absorption order,
and the hash value is invariant under associativity-respecting re-schedulings.

Why now? The comb bridge gives a verified equality between a structural recursion
(`treeHash`) and a tail recursion (`foldl`/`merkleDamgard`); generalizing the
accumulator from a single value to a (rate, capacity) state is a small,
mechanizable step from the existing `treeHash_leftCombAux` induction.

## Direction 4: Authentication-path soundness (Merkle proofs)

Conjecture: Define a Merkle membership proof as the list of sibling hashes along
a root-to-leaf path. Then, assuming `h` is collision resistant, a verifier that
recomputes the root accepts a forged leaf at a fixed position only if it can
exhibit an explicit `h`-collision — i.e. authentication-path soundness reduces to
compression collision resistance exactly as `treeHash_inj_sameShape` does for the
whole tree.

The key insight is that an authentication path is a `foldr` of `h` over the
sibling list, so path verification is *the same recursion* as `treeHash`
restricted to a spine; soundness is therefore a localized instance of the joint
injectivity already proven, not a new hardness assumption.

Why now? Git, Bitcoin, and Certificate Transparency all rely on this exact
property informally; the `leftCombAux`/`foldl` correspondence we proved is the
missing formal scaffold to state and discharge it as a corollary.

## Direction 5: Second-preimage resistance separates from collision resistance on trees

Conjecture: There is a compression `h` that is collision resistant on same-shape
inputs yet for which `treeHash` (without domain separation) admits an efficient
*second-preimage* finder via shape manipulation — formally, the predicate "every
adversary outputting a same-shape second preimage yields an `h`-collision" holds,
while the cross-shape version provably fails, witnessed by a generalization of
`tree_cross_shape_collision_exists`.

The key insight is that collision resistance is a statement about *two unknown*
inputs whereas second-preimage resistance fixes one; the shape degree of freedom
exploited in `tree_cross_shape_collision_exists` attacks only the latter, giving
a clean formal separation between the two security notions on tree hashes.

Why now? We already have both the positive same-shape reduction and the explicit
cross-shape counterexample in the same file; making the separation precise only
requires phrasing the two adversary classes and quoting the existing theorems.

**Concept description**: # Future Directions: Merkle Tree Hashing and Collision Resistance

This cycle extended the linear Merkle–Damgård collision-resistance theory
(`Cryptography.MerkleDamgard`: `merkleDamgard`, `foldl_joint_injective`,
`compress_injective_md_injective`, `md_collision_implies_compress_collision`)
to *binary hash trees* in `Cryptography.MerkleTreeHash`. The new file proves:

- `treeHash_inj_sameShape` — injectivity of the tree hash on same-shape trees;
- `tree_collision_implies_compression_collision` — the security reduction
  (a tree collision yields a leaf-map or compression collision);
- `treeHash_inj_domainSeparated` — full cross-shape injectivity once leaf- and
  node-hashes are domain-separated;
- `treeHash_leftComb_eq_merkleDamgard` — the bridge identifying Merkle–Damgård
  as the left-comb (linear) special case of tree hashing;
- `tree_cross_shape_collision_exists` — a boundary counterexample showing the
  same-shape / domain-separation hypotheses are necessary.

The directions below are concrete, falsifiable next steps.

## Direction 1: Quantitative multi-collision bounds for shaped trees

Conjecture: For a compression `h : α → α → α` with at most `c` collision pairs,
the number of distinct trees of a *fixed* shape `S` with `n` leaves that share a
common root hash is bounded by a polynomial `P_S(c, n)` whose degree equals the
number of internal nodes of `S`, and this bound is tight for "balanced" shapes.

The key insight is that a fixed shape turns the hash into a *layered* composition
of `h`, so multi-collisions factor through per-node collision multiplicities; the
shape's internal-node count controls how these multiplicities multiply. This
upgrades the qualitative reduction `tree_collision_implies_compression_collision`
to a counting statement, the tree analogue of Joux multicollisions for
Merkle–Damgård.

Why now? We already have `treeHash_inj_sameShape`, which is exactly the `c = 0`
base case; the inductive skeleton of its proof (peel one `h`-layer, recurse on
both subtrees) is the natural carrier for a multiplicity-counting induction.

## Direction 2: Length/shape-tagging realizes domain separation generically

Conjecture: For any injective `g` and injective `h`, the *tagged* tree hash
`treeHash (Sum.inl ∘ g) h'` — where `h'` writes node outputs into a disjoint tag
class — automatically satisfies the `hsep` hypothesis of
`treeHash_inj_domainSeparated`, hence is fully (cross-shape) collision resistant
with *no* extra assumption beyond injectivity of `g` and `h`.

The key insight is that the abstract obstruction in
`tree_cross_shape_collision_exists` is precisely the *overlap* between the range
of `g` and the range of `h`; a one-bit tag forces these ranges disjoint, so
domain separation is not an extra hypothesis but a free encoding transformation.

Why now? `treeHash_inj_domainSeparated` isolates `hsep` as the single missing
ingredient, and `tree_cross_shape_collision_exists` pinpoints range-overlap as
the only failure mode — so the conjecture is a constructive closing of exactly
that gap.

## Direction 3: Sponge / unbalanced-tree hashing unifies with the comb bridge

Conjecture: The bridge `treeHash_leftComb_eq_merkleDamgard` generalizes to an
equivalence between *any* binary-tree hashing schedule and an iterated
"absorb/squeeze" sponge over a 2-to-1 permutation, with collision resistance of
one transferring to the other up to the shape's depth.

The key insight is that `leftCombAux` is literally a `foldl`, i.e. a degenerate
sponge with capacity zero; replacing the comb's right spine of leaves by an
arbitrary tree schedule is the same as choosing a non-trivial absorption order,
and the hash value is invariant under associativity-respecting re-schedulings.

Why now? The comb bridge gives a verified equality between a structural recursion
(`treeHash`) and a tail recursion (`foldl`/`merkleDamgard`); generalizing the
accumulator from a single value to a (rate, capacity) state is a small,
mechanizable step from the existing `treeHash_leftCombAux` induction.

## Direction 4: Authentication-path soundness (Merkle proofs)

Conjecture: Define a Merkle membership proof as the list of sibling hashes along
a root-to-leaf path. Then, assuming `h` is collision resistant, a verifier that
recomputes the root accepts a forged leaf at a fixed position only if it can
exhibit an explicit `h`-collision — i.e. authentication-path soundness reduces to
compression collision resistance exactly as `treeHash_inj_sameShape` does for the
whole tree.

The key insight is that an authentication path is a `foldr` of `h` over the
sibling list, so path verification is *the same recursion* as `treeHash`
restricted to a spine; soundness is therefore a localized instance of the joint
injectivity already proven, not a new hardness assumption.

Why now? Git, Bitcoin, and Certificate Transparency all rely on this exact
property informally; the `leftCombAux`/`foldl` correspondence we proved is the
missing formal scaffold to state and discharge it as a corollary.

## Direction 5: Second-preimage resistance separates from collision resistance on trees

Conjecture: There is a compression `h` that is collision resistant on same-shape
inputs yet for which `treeHash` (without domain separation) admits an efficient
*second-preimage* finder via shape manipulation — formally, the predicate "every
adversary outputting a same-shape second preimage yields an `h`-collision" holds,
while the cross-shape version provably fails, witnessed by a generalization of
`tree_cross_shape_collision_exists`.

The key insight is that collision resistance is a statement about *two unknown*
inputs whereas second-preimage resistance fixes one; the shape degree of freedom
exploited in `tree_cross_shape_collision_exists` attacks only the latter, giving
a clean formal separation between the two security notions on tree hashes.

Why now? We already have both the positive same-shape reduction and the explicit
cross-shape counterexample in the same file; making the separation precise only
requires phrasing the two adversary classes and quoting the existing theorems.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v8 Depth Requirements -- Research Team Protocol

You are leading a research team. Your team has different roles:
- The **Hypothesizer** generates bold, falsifiable conjectures
- The **Experimenter** proves or disproves them in Lean 4
- The **Analyst** examines what survived, what failed, and WHY
- The **Critic** searches for weaknesses, constructs counterexamples,
  and identifies where proofs might break down. A well-constructed
  counterexample is as valuable as a proof.
- The **Synthesist** upgrades the knowledge base and writes the
  FUTURE_DIRECTIONS.md that seeds the next cycle

You run this loop: **Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate**.
Each cycle is not a one-shot task. It is one iteration of an infinite
research process. Your notes (FUTURE_DIRECTIONS.md, Lab Notebooks,
proof sketches) determine whether the next team builds on your work
or starts over.

**Take good notes.** A cycle without useful notes is a wasted cycle.

### STEP 1: THEOREM DECLARATIONS (required -- before any code)

List every theorem you intend to prove or investigate. For each, state:
- **Name**: The Lean declaration name
- **Statement**: One-sentence informal statement
- **Status**: `hypothesis` | `conjecture` | `proved` | `proved_with_lemma_sorry` | `disproved`
- **Why it matters**: One sentence on what this result would mean if true,
  and what it would teach us if false

Example:
1. `cantorPairing_surjective`: Cantor pairing is surjective -- proved -- constructive inverse -- confirms decidability of Nat x Nat
2. `cantorPairing_injective`: Cantor pairing is injective -- proved -- diagonal argument -- confirms invertibility
3. `cantorPairing_bijection`: Cantor pairing is a bijection -- proved_with_lemma_sorry -- follows from 1+2 -- completing the characterization

Use `hypothesis` for statements you are not yet sure you can prove but
want to investigate. Use `conjecture` for statements you believe are true
but cannot prove in this cycle. Use `disproved` for statements where you
found a counterexample. Use `proved` for statements with complete Lean
proofs. Use `proved_with_lemma_sorry` when the main proof is complete but
one or more supporting lemmas use `sorry`.

### STEP 2: EXPERIMENT (prove or disprove in Lean 4)

Every theorem declared as `proved` MUST have a complete, compiling Lean proof.
No `sorry` on the main result. If you cannot complete a proof, change its
status to `conjecture` or `proved_with_lemma_sorry` and explain why.

For `proved_with_lemma_sorry`:
- The theorem statement must be complete (no sorry in the statement)
- `sorry` is allowed ONLY in supporting lemmas, never the main proof
- A comment must explain what the sorry replaces and why it is deferred

**Disproofs count.** If a hypothesis is false, prove its negation or
construct an explicit counterexample. A well-constructed counterexample
is as valuable as a proof. Change the status to `disproved` and state
the counterexample clearly.

### STEP 3: CRITIQUE (find the weaknesses)

For your best theorem, the Critic must:
- Identify the strongest assumption that could be weakened
- Construct a boundary case: where does the result break down?
- If possible, state a `conjecture` for the generalized version and
  explain what would need to change in the proof

This is NOT optional. A theorem without a critique is incomplete.

### STEP 4: Anti-patterns (reject these)

These tactics indicate trivial proofs:
- `native_decide` / `decide` / `norm_num` / `rfl` -- unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on any theorem declared as `proved`

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for conjectures, generalizations, and boundary cases.

### STEP 5: Novelty

Your theorems must be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### STEP 6: TAKE GOOD NOTES (first-class deliverables)

Your notes determine what the next research team investigates. They are NOT
an afterthought. They are your most important output after the proofs themselves.

**6a. Lab Notebook** (in each .lean file, as `-- !-- Lab Notebook -- !--` blocks):

For each major theorem, include a Lab Notebook comment block:
```lean
-- !-- Lab Notebook: cantorPairing_bijection -- !--
-- !-- Hypothesis: Cantor pairing is bijective because both surjective and injective -- !--
-- !-- Result: Proved via composition of surjective and injective proofs -- !--
-- !-- Insight: The constructive inverse of surjectivity is key; diagonal argument handles injectivity -- !--
-- !-- Failure analysis: Initial attempt to prove bijection directly failed; decomposition into surjective+injective was necessary -- !--
-- !-- End Lab Notebook -- !--
```

**6b. FUTURE_DIRECTIONS.md** (MANDATORY — your output WILL BE REJECTED if missing):

You MUST produce a FUTURE_DIRECTIONS.md file with this EXACT structure.
Copy the section headers below verbatim. Do NOT use freeform prose.

## Synthesis

[2-3 paragraphs: what did this cycle discover? What failed and why? What
structural insight emerged? Tie the directions together into a narrative.]

## Results Summary

[For EACH theorem: name, status (proved/conjecture/disproved), one-sentence
significance. Format as a bullet list:]

- `theoremName`: status — one-sentence significance

## Research Directions

### Direction 1: [Concise title]
**Hypothesis**: A precise, falsifiable mathematical statement.
**Test**: What experiment (proof/disproof/computation) would confirm or refute it.
**Why now**: What from THIS cycle makes this tractable.
**If true**: What new territory this opens.
**If false**: What the failure teaches us.

[Repeat for 3-5 directions]

IMPORTANT: The ## Synthesis and ## Results Summary sections are NOT optional.
If your FUTURE_DIRECTIONS.md is missing either section, it will be treated as
incomplete and the next research team will have no context to build on your work.

### STEP 7: Generalization loop

For your BEST theorem, attempt one level of generalization:
- State a stronger version (can use sorry if proving would take too long)
- Identify the boundary: where does the result break down?
- If the generalization is itself interesting, mark it as a `conjecture`
  in your theorem declarations and explain it in FUTURE_DIRECTIONS.md

### Output format

Your output must include:
1. `.lean` files with proofs and Lab Notebook blocks (structured as declared in Step 1)
2. `FUTURE_DIRECTIONS.md` with Synthesis, Results Summary, and 3-5 research
   directions (structured as in Step 6b)

Both are required. A cycle with proofs but no Lab Notebook or
FUTURE_DIRECTIONS.md is a cycle where the next team starts from scratch.
Take good notes.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
