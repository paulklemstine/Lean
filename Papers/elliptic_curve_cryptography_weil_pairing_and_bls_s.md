# Skip Evidence Justification

The results in this cycle are **universal algebraic identities over an abstract
bilinear-pairing interface** (`Pairing G T`: any biadditive map from an additive
abelian group into a multiplicative abelian group). They are quantified over *all*
groups and *all* pairings, so there is no finite parameter to sweep and no
numerical counterexample hunt that could add information beyond the proofs
themselves:

- Bilinearity, BLS completeness, aggregation, and the MOV congruence
  (`WeilPairingBLS`, `WeilPairingMOV`) are scalar/exponent laws that hold by
  induction for every pairing.
- The unforgeability reduction (`bls_forgery_solves_cdh`,
  `bls_adversary_solves_cdh`, `cdh_hard_implies_no_forger`) is a deterministic
  equality forced by nondegeneracy; the only "data" is the abstract hypothesis
  that the pairing separates points against the fixed generator.
- The rogue-key attack (`rogue_key_attack`) is an *exact* group identity
  (`X₁ + (w•g − X₁) = w•g`) composed with bilinearity, so it already constitutes
  its own concrete witness — it is a proved equation, not a statistical claim.

A small-case numerical table (e.g. a concrete pairing `e(a,b) = ζ^{ab}` on
`ZMod n` into roots of unity) would merely re-instantiate identities that are
proved in full generality, and every theorem here is machine-checked with no
`sorry` and only the standard axioms. Computational evidence is therefore
redundant for these universally quantified algebraic facts.
