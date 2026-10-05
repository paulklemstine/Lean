# Call the ORIGINAL attack_gifp_instance (primary source, unmodified) and see what it returns.
_g = globals(); _g['__name__'] = 'orig'
exec(compile(open('/home/raver1975/lean/Experiments/UMWWindow/gifp_ref/gifp.sage').read(),'gifp.sage','exec'), _g)
_g['__name__'] = 'orig2'
r = _g['attack_gifp_instance'](200, 0.10, 0.70, 0.10, 0.15, 4, seed=5000000)
print("ORIGINAL attack_gifp_instance returned:", r)
