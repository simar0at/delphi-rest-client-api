unit IdOpenSSLConsts;

interface

{$i IdCompilerDefines.inc}

const
  CLibCryptoRaw = 'libcrypto';
  CLibSSLRaw = 'libssl';

  SSLDLLVers: array [0..1] of string = ('', '.1.1');

  CLibCrypto =
    CLibCryptoRaw + '-1_1.dll';
  CLibSSL =
    CLibSSLRaw + '-1_1.dll';

implementation

end.
