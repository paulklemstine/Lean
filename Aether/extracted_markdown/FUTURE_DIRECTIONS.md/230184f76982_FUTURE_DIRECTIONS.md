# Future Directions — Temporal Gödel–Löb Logic (TGL)

The module `Logic/TemporalGL.lean` lays the semantic and algebraic foundations of a
*temporal* provability logic: provability indexed by discrete time, with a Gödel–Löb
accessibility relation `R` for proof structure and a temporal preorder `T` for the
flow of discovery. We proved soundness of Löb's axiom and the `4` axiom on temporal
GL frames, the new temporal interaction axiom `□A → □□◇A`, the persistence of
provability `□A → G□A`, the refutability of the temporal paradox "provable today but
not tomorrow" together with the satisfiability of its mirror, and both a semantic and a
time-stamped form of Gödel's second incompleteness theorem. The following directions
are concrete, falsifiable, and build directly on those results.

## 1. Arithmetical completeness of TGL over Peano Arithmetic

The structure `TempProv` axiomatises a time-stamped provability predicate, and
`trivialTempProv_consistent` shows the axioms are consistent — but only via the
degenerate "proves nothing" model. The real test is to construct a *faithful* model
where `prov t A` is interpreted in PA as "there exists a PA-proof of `A` with Gödel
number (or proof length) at most `t`", and to prove a Solovay-style arithmetical
completeness theorem: a temporal modal sentence is a theorem of TGL iff its
arithmetical interpretation is a theorem of PA under every time-stamped substitution.
**The key insight is** that bounded provability `Prov(t, A)` is itself Σ₁, so positive
introspection (`sigma1`) and persistence both hold of the *honest* arithmetical
predicate, not just of toy models — meaning the abstract `TempProv` axioms are exactly
the PA-valid principles. **Why now?** The catalog already contains the GL Solovay
infrastructure in spirit (`GLPLogic.loeb_valid`, `second_incompleteness`,
`GLKripke.gl_frame_validates_loeb`); the only genuinely new ingredient is the bounded,
time-indexed predicate, which is mechanically definable from a Gödel encoding.
*Falsifiable:* exhibit a temporal modal sentence valid in every `TempProv` model but
whose arithmetical interpretation is independent of PA (this would refute completeness).

## 2. Decidability via the temporal finite model property

GL has the finite model property and is decidable; `boolTempFrame` shows TGL frames
can be finite. Conjecture: TGL has a *temporal* finite model property — every
non-theorem is refuted on a frame that is finite in both the `R` and `T` dimensions —
and is therefore decidable, with an explicit `PSPACE` (or better) bound. **The key
insight is** that `compat` (time-monotonicity of `R`-successors) lets a temporal model
be unravelled into a finite product of a converse-well-founded `R`-tree with a finite
linear time order, so the two well-foundedness phenomena (proof depth and bounded
time) compose rather than interfere. **Why now?** `loeb_box_sound` and
`provability_persists` already isolate the two axes cleanly; a filtration argument over
`TempFrame` is the natural next lemma. *Falsifiable:* find a TGL non-theorem with no
finite countermodel (would refute the finite model property and likely decidability).

## 3. Strictness: TGL is a proper extension of GL

We proved `tgl_axiom_sound` (`□A → □□◇A` is sound on temporal frames). Conjecture:
this axiom is *not* derivable in GL, so TGL strictly extends GL. **The key insight is**
that `◇` here is the *temporal* eventually-operator `Fut T`, decoupled from the GL
diamond on `R`; on a frame where `T` is non-trivial but `R` is empty at the current
world, the GL-diamond `◇` collapses while the temporal `◇` does not, separating the two
logics. **Why now?** The two-relation `TempFrame` already makes the separating model a
one-line variant of `boolTempFrame`; formalising "`φ` is GL-valid" using the catalog's
`GLPLogic.GLFrame.valid` gives a direct non-derivability target. *Falsifiable:* a
GL-frame proof of `□A → □□◇A` from the GL axioms would collapse the extension.

## 4. Temporal Gödel–Löb fixed points and self-referential discovery

GL enjoys the de Jongh–Sambin fixed-point theorem: every formula `φ(p)` with `p` only
under `□` has a provably equivalent fixed point. Conjecture: a *temporal* fixed-point
theorem holds, and it makes precise which self-referential temporal statements (e.g.
"this sentence becomes provable exactly at time `t₀`") are realisable and which are
paradoxical. **The key insight is** that `today_not_tomorrow_refuted` and
`tomorrow_not_today_satisfiable` already classify the simplest such sentences by the
*direction* of the temporal claim; the fixed-point calculus should turn this asymmetry
into a decision procedure for arbitrary timed self-reference. **Why now?** Persistence
(`provability_persists`) gives the monotonicity that forces the fixed-point iteration
to converge in finitely many time steps. *Falsifiable:* a temporal fixed-point formula
with no provably-equivalent timed solution would refute the conjecture.

## 5. Proof mining: extracting discovery schedules from temporal derivations

If TGL is arithmetically complete (Direction 1) and decidable (Direction 2), then a
TGL derivation of `◇A` ("`A` will be provable") should carry *quantitative* content:
an explicit time bound `t` by which `A` becomes provable. Conjecture: there is a
realizability/extraction map sending a TGL proof of `Fut T A` to a numeral `t` with
`prov t A`, refining `future_self_certification`. **The key insight is** that the
converse-well-founded induction in `loeb_box_sound` is *constructive in the ordinal
height of `R`*, so the same recursion that validates Löb also computes the stage at
which a proof first appears. **Why now?** Modern proof-mining (the monotone Dialectica
/ bounded-functional interpretation) is exactly designed to extract such bounds from
modal/well-founded arguments, and the catalog's GL well-foundedness lemmas
(`GLKripke.gl_frame_well_founded`) supply the termination measure. *Falsifiable:*
a TGL-provable `Fut T A` for which no computable time bound exists would refute
extractability.
