# RESULT — catalog-inspired screening of ECDSA's pairing route and HD cascade

Round 118, `r118/catalog-screening/`. Two verified results, both catalog-native.

## 1. Pairing route: closed below 2^40, by complete search

`embdeg.sage`. The catalog's `WeilPairingClassification` needs a non-degenerate pairing on
`E[n]`, hence `n | p^k - 1` for small `k`. Since `n` is prime, `ord_n(p) | n-1`, so every
candidate embedding degree is a **divisor of `n-1`** — a finite, checkable set.

```
secp256k1 : n-1 has 7 prime factors (largest 109-bit); 55 divisors < 2^40 tested, none works
P-256     : n-1 has 12 prime factors (largest  92-bit); 489 divisors < 2^40 tested, none works
Curve25519: n-1 has 5 prime factors (largest 138-bit); 11 divisors < 2^40 tested, none works
```

Closed below `2^40` for all three deployed curves, and `ord_n(p) >= 92...138` bits
rigorously (the largest prime factor of `n-1` must divide the order). Not "asserted large" —
searched.

## 2. HD cascade: one signature verifies under 2^31 keys

`cascade.sage` + `harden.sage`, real secp256k1, realistic public offsets.

- transfers to every other address of the same BIP44 account: **8/8**;
- amplification: **`2^31 = 2,147,483,648`** verifying `(key, message)` pairs per single
  signature, cost one scalar multiplication;
- hardening: 0/11 structured candidate messages verify; the single working message needs
  the 256-bit private offset, so the transfer is free when `lam` is public and impossible
  when it is private;
- framing: the catalog's `cascade_cost_efficiency`/`cascade_dominates` are defender-side
  cost models. The attacker's dual is that the cascade **does not add security per key**,
  because the keys are related by public translations.

## 3. Reproduce

```
cd /home/raver1975/lean/factor-scratch/r118/catalog-screening
/home/raver1975/sage_mamba/envs/sage/bin/sage embdeg.sage
/home/raver1975/sage_mamba/envs/sage/bin/sage cascade.sage
/home/raver1975/sage_mamba/envs/sage/bin/sage harden.sage
```

## 4. Trap recorded

`cascade.sage`'s first "hardening kills it" test signed with the hardened child's own key,
so it verified trivially and the `True` meant nothing. The corrected test (`harden.sage`)
signs under the **account** key and restricts the attacker to messages constructible from
public data, which is the honest search space. *A control must test the attacker's option,
not the defender's convenience.*
