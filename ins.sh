#!/data/data/com.termux/files/usr/bin/bash
#
# Encrypted by Rangga Fajar Oktariansyah (Anak Gabut Thea)
#
# This file has been encrypted with BZip2 Shell Exec <https://github.com/FajarKim/bz2-shell>
# The filename 'ins.sh' encrypted at Mon Jun 10 18:09:00 +0330 2024
# I try invoking the compressed executable with the original name
# (for programs looking at their name).  We also try to retain the original
# file permissions on the compressed file.  For safety reasons, bzsh will
# not create setuid or setgid shell scripts.
#
# WARNING: the first line of this file must be either : or #!/bin/bash
# The : is required for some old versions of csh.
# On Ultrix, /bin/bash is too buggy, change the first line to: #!/bin/bash5
#
# Don't forget to follow me on <https://github.com/FajarKim>
skip=76
set -e

tab='	'
nl='
'
IFS=" $tab$nl"

# Make sure important variables exist if not already defined
# $USER is defined by login(1) which is not always executed (e.g. containers)
# POSIX: https://pubs.opengroup.org/onlinepubs/009695299/utilities/id.html
USER=${USER:-$(id -u -n)}
# $HOME is defined at the time of login, but it could be unset. If it is unset,
# a tilde by itself (~) will not be expanded to the current user's home directory.
# POSIX: https://pubs.opengroup.org/onlinepubs/009696899/basedefs/xbd_chap08.html#tag_08_03
HOME="${HOME:-$(getent passwd $USER 2>/dev/null | cut -d: -f6)}"
# macOS does not have getent, but this works even if $HOME is unset
HOME="${HOME:-$(eval echo ~$USER)}"
umask=`umask`
umask 77

bztmpdir=
trap 'res=$?
  test -n "$bztmpdir" && rm -fr "$bztmpdir"
  (exit $res); exit $res
' 0 1 2 3 5 10 13 15

case $TMPDIR in
  / | */tmp/) test -d "$TMPDIR" && test -w "$TMPDIR" && test -x "$TMPDIR" || TMPDIR=$HOME/.cache/; test -d "$HOME/.cache" && test -w "$HOME/.cache" && test -x "$HOME/.cache" || mkdir "$HOME/.cache";;
  */tmp) TMPDIR=$TMPDIR/; test -d "$TMPDIR" && test -w "$TMPDIR" && test -x "$TMPDIR" || TMPDIR=$HOME/.cache/; test -d "$HOME/.cache" && test -w "$HOME/.cache" && test -x "$HOME/.cache" || mkdir "$HOME/.cache";;
  *:* | *) TMPDIR=$HOME/.cache/; test -d "$HOME/.cache" && test -w "$HOME/.cache" && test -x "$HOME/.cache" || mkdir "$HOME/.cache";;
esac
if type mktemp >/dev/null 2>&1; then
  bztmpdir=`mktemp -d "${TMPDIR}bztmpXXXXXXXXX"`
else
  bztmpdir=${TMPDIR}bztmp$$; mkdir $bztmpdir
fi || { (exit 127); exit 127; }

bztmp=$bztmpdir/$0
case $0 in
-* | */*'
') mkdir -p "$bztmp" && rm -r "$bztmp";;
*/*) bztmp=$bztmpdir/`basename "$0"`;;
esac || { (exit 127); exit 127; }

case `printf 'X\n' | tail -n +1 2>/dev/null` in
X) tail_n=-n;;
*) tail_n=;;
esac
if tail $tail_n +$skip <"$0" | bzip2 -cd > "$bztmp"; then
  umask $umask
  chmod 700 "$bztmp"
  (sleep 5; rm -fr "$bztmpdir") 2>/dev/null &
  "$bztmp" ${1+"$@"}; res=$?
else
  printf >&2 '%s\n' "Cannot decompress ${0##*/}"
  printf >&2 '%s\n' "Report bugs to <fajarrkim@gmail.com>."
  (exit 127); res=127
fi; exit $res
BZh91AY&SY��/  �_�D}��_//_����P{۝���i]��H��&0�������=� dcS@z�f��P����mOQ��     ��(����=C�Q�24�h  � �`�2��I%=����S��Ѧ� � 2�H/���w����]�'ݿ븭�O��|0x�4�Z�%��m���*eX4:��(Y����V�9Ƙ����h#�<5 ��*�����;k�%�53���=���>�N�ŀ���kX��Cc�kk�_P��dA4q\�
(|��~�űKՎ���ڠYS��m-ۏ+P��L!��=_����pY���ls>c��+�`-�fc�.Pq4�3l=�,�e�!��h���N�ӟQ�>�+u����	o���'��k�).q���K�v��_h���� �307���&�b�)���+�^g���[�<��l�ܠ �$Yu 1�ӣ��e�T>�6�,�̍\���v�g� ��}I""1�9��54�K#�	�
�]���߿΂Vo'X�\�3$de��R�� ��`珍�6&��s�aQ@h�����ѷHz)�%~o�"Ң�g������r7֥;f��%�Ի�S��)^H�'
��P��[J���\��R�$+LX�D��gA���7��R�Cb-q�5d̍l�Q(��d�~�%i�8�yI�̉� �
�[#Q"M����/f/{�8P���D�8*���Ugsr�&N*W���0Pl�CL-�Ejڦv�n��cm1v
�8�1dJq��e�Me�(�2�.� �2E�6�����5�+.AS.�F�V6�1����&Ԥ<��5p�E/&�!)*	9a*VR�uq9���j9k����C:J�5UJ!^4�<Mq>⡶����n�<Zi;��]��BB|Kt�