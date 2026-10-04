print("== #523 s6.2 INTERNAL CONTRADICTION ==\n")
print("Paper claim (bold, line 296): 'The gain SURVIVES sieving -- the audit's \"every net")
print("   gain < 1\" is false.'  Evidence cited: '12-16 of 16 mod-4 and 7-9 of 9 mod-3")
print("   sub-boxes have ratio > 1.'\n")
print("Paper qualification 1 (line 308-310): 'It is not an implementable speedup. There is no")
print("   decision to take: no sub-box beats the free global rate.'\n")
print("SOURCE results.txt line 283 defines the test explicitly:")
print("   'If some sub-box beats the global ratio, the gain IS localisable and a sieve could")
print("    be aimed at it.'\n")
data=[(64,6.00,28.400,5.0225),(128,5.14,14.0152,3.0520),(256,4.50,8.0273,2.1607),
      (512,4.00,5.1431,1.7141),(1024,3.60,3.9177,1.5073),(4096,3.00,2.5950,1.2709)]
print(f"{'B':>6} {'u':>6} {'max sub-box (mod4)':>20} {'global rate ratio':>19}  beats global?")
for B,u,mx,g in data:
    print(f"{B:>6} {u:>6.2f} {mx:>20.4f} {g:>19.4f}  {'YES' if mx>g else 'no'}")
print()
print(f"Every B beats the global rate. At u=6.00 by {28.400/5.0225:.2f}x; at u=3.00 by {2.5950/1.2709:.2f}x.")
print("=> Under the source's OWN criterion, the gain IS localisable at every operating point.")
print("=> Qualification 1 ('no sub-box beats the free global rate') is FALSE by the data it cites.")
print("=> And it flatly contradicts the bolded claim 12 lines above it in the SAME section.")
