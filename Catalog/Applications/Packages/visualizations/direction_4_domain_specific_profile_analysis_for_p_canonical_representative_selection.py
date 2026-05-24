def select_canonical_representatives(certs):
    minimal = []
    for cert in sorted(certs, key=len):
        if not any(m < cert for m in minimal):
            minimal.append(cert)
    return minimal

# Example
certs = [
    frozenset([(3,4,5)]),
    frozenset([(3,4,5), (5,12,13)]),
    frozenset([(5,12,13)]),
    frozenset([(3,4,5), (5,12,13), (8,15,17)]),
]
reps = select_canonical_representatives(certs)
print(f"Certificates: {len(certs)}, Representatives: {len(reps)}")
for r in reps:
    print(f"  {set(r)}")