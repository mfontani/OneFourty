package OneFourty::XSlateStrings;

use Exporter 'import';

@EXPORT    = qw<strlen>;
@EXPORT_OK = qw<strlen>;

sub strlen { length $_[0] }

1;
