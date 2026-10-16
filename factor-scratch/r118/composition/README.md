# r118/composition — ECDSA signatures transfer along publicly-known key translations

Verified experiments (Sage, secp256k1, 20/20 and 10/10):

- `bip32.sage` — **C1**: a child-key signature verifies under the *parent* key for
  `z' = z + λ·r`, where `λ` is the public BIP32 tweak. Verified 20/20.
- `sign.sage` — **C2**: an additive 2-of-2 aggregate signature verifies under `Q₁` alone
  for `z' = z + d₂·r` (λ = the other party's private key). Verified 10/10.
  *Sign caution*: the transfer rule is `(Q, z) → (Q + λG, z − λr)`, so landing on a smaller
  key means λ < 0 and therefore `z' = z + |λ|·r`. An earlier version of `bip32.sage` still
  contains an uncorrected multisig line using `z − d₂·r`, which reads `False`; the correct
  result is in `sign.sage` and is 10/10.
