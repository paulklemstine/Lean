#!/usr/bin/env python3
"""Broad sweep: pull large result sets into a local JSONL corpus for offline grepping."""
import json, os, time, sys
from ax import search

HERE = os.path.dirname(os.path.abspath(__file__))
CORPUS = os.path.join(HERE, 'corpus.jsonl')

QUERIES = [
    'abs:"number field sieve"',
    'abs:"elliptic curve method"',
    'abs:"general number field sieve"',
    'abs:"factorization" AND abs:"RSA" AND abs:lattice',
    'abs:"index calculus"',
    'abs:factoring AND abs:"Coppersmith"',
    'abs:factoring AND abs:"partial" AND abs:"bits"',
    'abs:"known bits" AND abs:factoring',
    'abs:"side-channel" AND abs:"RSA" AND abs:factoring',
    'abs:"factoring" AND abs:"smooth" AND abs:"complexity"',
    'abs:"lower bound" AND abs:factoring AND cat:cs.CC',
    'abs:"quantum factoring" AND abs:"query complexity"',
    'abs:"integer factorization" AND abs:"heuristic"',
    'abs:factoring AND abs:"special form" AND abs:primes',
    'abs:"SNFS" OR abs:"special number field sieve"',
    'abs:factoring AND abs:"high precision" AND abs:divisors',
    'abs:"multi-polynomial" AND abs:sieve',
    'abs:"tensor" AND abs:factoring AND abs:sieving',
    'abs:"ECM" AND abs:"elliptic curve" AND abs:primes',
    'abs:"factoring" AND cat:cs.DS AND abs:lattice',
    'abs:"post-quantum" AND abs:factoring AND abs:"classical"',
    'abs:factoring AND abs:"auxiliary" AND abs:information',
    'abs:"Schnorr" AND abs:sieving AND abs:factoring',
    'abs:"satellite" AND abs:factoring',
    'abs:"relation" AND abs:"modular" AND abs:"hyperbola" AND abs:factoring',
    'abs:factoring AND abs:"constant factor" AND abs:sieve',
    'abs:"Sherman" AND abs:"sieve"',
    'abs:"linear algebra" AND abs:factoring AND abs:modulus',
    'abs:factoring AND abs:"distributed" AND abs:"modulus"',
    'abs:"staged" AND abs:factoring',
    'abs:"NFS" AND abs:"implementation" AND abs:factor',
    'abs:"b-smooth" AND abs:"p^2" AND abs:factor',
    'abs:"p+1" AND abs:"p-1" AND abs:factoring',
    'abs:"Williams" AND abs:"p+1" AND abs:factoring',
    'abs:"class group" AND abs:factoring AND abs:order',
    'abs:"order-finding" AND abs:"classical" AND abs:factoring',
    'abs:"sub-exponential" AND abs:factoring AND abs:"lower bound"',
    'abs:factoring AND abs:"Shor" AND abs:"classical simulation"',
    'abs:"Vandermonde" AND abs:factoring',
    'abs:"nonlinear" AND abs:"modulus" AND abs:factoring',
    'abs:"G(entry)" AND abs:factoring',
    'abs:factoring AND abs:"bivariate"',
    'abs:"multivariate" AND abs:factoring AND abs:lattice',
    'abs:factoring AND abs:"norm" AND abs:"Euclidean"',
    'abs:"modular hyperbola" AND abs:factoring',
    'abs:"congruence of squares" AND abs:factoring',
    'abs:factoring AND abs:"pollard" AND abs:"rho"',
    'abs:"Williams p+1"',
    'abs:"Strassen" AND abs:factoring',
    'abs:"Pollard" AND abs:"p-1" AND abs:factor',
    'abs:"prime factor" AND abs:"random" AND abs:proven',
    'abs:factoring AND abs:"record" AND abs:"bits"',
    'abs:"CADO" OR abs:"factor"',
    'abs:"factorization of integers" AND abs:"reproducibility"',
    'abs:"equidistribution" AND abs:"modular" AND abs:factoring',
    'abs:"Dickman" AND abs:factoring',
    'abs:"smooth number" AND abs:"factoring" AND abs:heuristic',
    'abs:"p-1" AND abs:"B-smooth" AND abs:order',
    'abs:"factorization" AND abs:"Hilbert" AND abs:"polynomial"',
]

def main():
    seen = {}
    if os.path.exists(CORPUS):
        for line in open(CORPUS):
            d = json.loads(line)
            seen[d['id'].split('v')[0]] = d
    before = len(seen)
    for q in QUERIES:
        try:
            tot, res = search(q, max_results=60)
            print('%-62s TOTAL=%s  new=%d' % (q[:62], tot, sum(1 for r in res if r['id'].split('v')[0] not in seen)), flush=True)
            for r in res:
                k = r['id'].split('v')[0]
                if k not in seen:
                    seen[k] = r
        except Exception as e:
            print('%-62s FAIL %s' % (q[:62], e), flush=True)
        time.sleep(3.5)
    with open(CORPUS, 'w') as f:
        for k in sorted(seen, key=lambda x: seen[x]['date'], reverse=True):
            f.write(json.dumps(seen[k]) + '\n')
    print('\nCORPUS: %d -> %d' % (before, len(seen)))

if __name__ == '__main__':
    main()
