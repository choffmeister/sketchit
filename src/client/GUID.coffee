define [], () ->
  hexDigits = "0123456789abcdef"
  
  class GUID
    @create: () ->
      # http://www.ietf.org/rfc/rfc4122.txt
      s = []

      for i in [0..35]
        r = Math.floor(Math.random() * 0x10)
        s[i] = hexDigits.substr(r, 1)

      # bits 12-15 of the time_hi_and_version field to 0010
      s[14] = 4
      # bits 6-7 of the clock_seq_hi_and_reserved to 01
      s[19] = hexDigits.substr((s[19] & 0x3) | 0x8, 1)
      # dashes
      s[8] = s[13] = s[18] = s[23] = "-";

      return s.join("")
