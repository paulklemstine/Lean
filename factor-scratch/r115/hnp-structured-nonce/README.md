Round 115 — Axis I (I1 / I2 / I6): nonce-structured lattice attacks on ECDSA.
Full report: RESULT.md.

Files
-----
  common.sage            harness: curves, EC/ECDSA arithmetic, instance generators,
                         all lattice constructions (plain HNP, LCG known-a, LCG secret-a,
                         GLV sublattice), trial runner. Self-contained; nothing is
                         imported from another round.
  exp_baseline.sage      plain HNP threshold curve (toy + secp256k1), 20 seeds x 2 seeds.
  exp_i1.sage            I1: r-statistics detector (exact TV, fold term, valid-abscissa
                         filter, biased-support cost, NULL false-positive case).
  exp_i2.sage            I2-A: LCG nonces, multiplier a KNOWN, vs plain HNP same instances.
  exp_i2b.sage           I2-B: LCG nonces, multiplier a SECRET (linearised lattice).
  exp_i2c.sage           I2 counting experiment (brute force, small scale): #d vs #(a,b,k1).
  exp_i2a_secp.sage      I2-A on secp256k1, m = 253.
  exp_i6.sage            I6: GLV box density (exact enumeration) + matched-leakage
                         sublattice vs plain range embedding + structure-only case.
  selftest.sage          positive-control sweep for every attack.
  verify_constructions.sage
                         for each lattice: build the true target vector from ground truth,
                         check it is IN the lattice, and compare |target| with the reduced
                         basis. Separates "construction right, attack cannot work" from
                         "construction buggy".
  debug_hnp*.sage, baseline_hnp.sage
                         development/debug scripts, kept for provenance.
  logs/                  raw output of every run plus JSON.

Reproduce
---------
  cd factor-scratch/r115/hnp-structured-nonce
  SAGE=/home/raver1975/sage_mamba/envs/sage/bin/sage
  $SAGE exp_baseline.sage 20 20261014 909090   # plain HNP baseline, both seeds
  $SAGE exp_i1.sage                             # I1 (fixed sampling, no seeds)
  $SAGE exp_i2.sage 20 20261014 909090          # I2-A + baseline on same instances
  $SAGE exp_i2b.sage 20 20261014 909090         # I2-B
  $SAGE exp_i2c.sage                            # I2 information counting
  $SAGE exp_i2a_secp.sage 4 20261014 909090     # I2-A on secp256k1
  $SAGE exp_i6.sage 20 20261014 909090          # I6

Conventions
-----------
  * success is always d*G == Q, verified by EC arithmetic
  * every count is produced under two fixed seeds and both are reported
  * the key appears in the reduced lattice as d or n-d; both signs are tested
  * LLL delta = 0.99, BKZ 2.0 block 20, fpylll 0.6.4

Headline results
----------------
  I1  REFUTED   only nonce-dependent statistic is TV = 2^-126.65 (10^77 signatures needed)
  I2  SUPPORTED when the multiplier a is known (t=4, ell=0 beats t*ell>=256)
      REFUTED   when a is secret (bilinear recurrence; 0/20 where baseline is 20/20)
  I6  REFUTED   GLV box image has density 1.0 -> the sublattice constraint is empty
