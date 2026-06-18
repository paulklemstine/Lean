# Summary of changes for run 0831edeb-f323-4bee-ad2e-0a2222148604
Created a new standalone Lean file `Catalog/Cryptography/KorseltConverse.lean` formalizing the requested composite-modulus theorem toward Korselt's criterion, with a complete, sorry-free, axiom-clean proof (verified to use only `propext`, `Classical.choice`, `Quot.sound`).

Main theorem (exactly as requested):
`ZMod.units_pow_sub_one_eq_one_of_squarefree_of_prime_dvd_imp` — for `n > 1` squarefree with `∀ p, p.Prime → p ∣ n → (p - 1) ∣ (n - 1)`, every `u : (ZMod n)ˣ` satisfies `u ^ (n - 1) = 1`.

The proof follows the genuine local-to-global (CRT) pipeline rather than a trivial exponent shortcut, supported by two minimal lemmas:
- `nat_dvd_of_squarefree_of_prime_dvd`: for squarefree `n`, `n ∣ m` whenever every prime divisor of `n` divides `m` (the squarefree = radical arithmetic content, proved via `Nat.factorization`).
- `zmod_eq_zero_of_squarefree`: the ring-level componentwise detection — `c : ZMod n` vanishes if all its reductions `ZMod.castHom hp (ZMod p) c` vanish over primes `p ∣ n`.

The main proof reduces the unit identity to the ring identity `(↑u)^(n-1) - 1 = 0` in `ZMod n`, checks it modulo each prime divisor `p` using that the image of the unit `u` is a nonzero element of the field `ZMod p`, applies Fermat's little theorem (`ZMod.pow_card_sub_one_eq_one`, giving exponent `p - 1`), bootstraps to exponent `n - 1` via the local hypothesis `(p - 1) ∣ (n - 1)`, and reassembles via the squarefree local-to-global lemma.

The file compiles successfully under the project's Mathlib (verified by building the module directly; the project's pre-existing default-target glob misconfiguration is unrelated to this file).