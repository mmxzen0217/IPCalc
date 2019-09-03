#include <Array.au3>


;==============================================
;   IP v4
;==============================================
;
;----------------------------------------------
;   IpIsValid
;----------------------------------------------
; Returns true if an ip address is formated exactly as it should be:
; no space, no extra zero, no incorrect value
Func _IpIsValid($ip)
	Local $IpIsValid=False
	$IpIsValid=(_IpBinToStr(_IpStrToBin($ip)) = $ip)
	Return $IpIsValid
EndFunc


;----------------------------------------------
;   IpStrToBin
;----------------------------------------------
; Converts a text IP address to binary
; example:
;   IpStrToBin("1.2.3.4") returns 16909060
func _IpStrToBin($ip)
	local $IpStrToBin=0
	Local $pos
	$ip=$ip&"."
	While $ip <>""
		$pos=StringInStr($ip,".")
		$IpStrToBin=$IpStrToBin*256+Int(StringLeft($ip,$pos-1))
		$ip=StringMid($ip,$pos+1)
	WEnd
	Return $IpStrToBin
EndFunc

;----------------------------------------------
;   IpBinToStr
;----------------------------------------------
; Converts a binary IP address to text
; example:
;   IpBinToStr(16909060) returns "1.2.3.4"
Func _IpBinToStr($ip)
	local $IpBinToStr
	local $divEnt
	local $i
	$i=0
	$IpBinToStr=""
	While $i <4
		if $IpBinToStr <>"" Then $IpBinToStr="."&$IpBinToStr
		$divEnt=Int($ip/256)
		$IpBinToStr=StringFormat($ip - ($divEnt * 256))&$IpBinToStr
		$ip=$divEnt
		$i=$i+1
	WEnd
	Return $IpBinToStr
EndFunc

;----------------------------------------------
;   IpAdd
;----------------------------------------------
; example:
;   IpAdd("192.168.1.1"; 4) returns "192.168.1.5"
;   IpAdd("192.168.1.1"; 256) returns "192.168.2.1"
Func _IpAdd($ip,$offset)
	Return(_IpBinToStr(_IpStrToBin($ip)+$offset))
EndFunc

;----------------------------------------------
;   IpAnd
;----------------------------------------------
; bitwise AND
; example:
;   IpAnd("192.168.1.1"; "255.255.255.0") returns "192.168.1.0"
func _IpAnd($ip1,$ip2)
	Local $result
	While (($ip1<>"" and ($ip2<>"")))
		Call(_IpBuild(BitAND(_IpParse($ip1) ,_IpParse($ip2)), $result))
	WEnd
	Return $result
EndFunc

;----------------------------------------------
;   IpOr
;----------------------------------------------
; bitwise OR
; example:
;   IpOr("192.168.1.1"; "0.0.0.255") returns "192.168.1.255"
Func _IpOr($ip1,$ip2)
	Local $result
	While (($ip1<>"" and ($ip2<>"")))
		Call(_IpBuild(BitOR(_IpParse($ip1) ,_IpParse($ip2)), $result))
	WEnd
	Return $result
EndFunc

;----------------------------------------------
;   IpXor
;----------------------------------------------
; bitwise XOR
; example:
;   IpXor("192.168.1.1"; "0.0.0.255") returns "192.168.1.254"
Func _IpXor($ip1,$ip2)
	Local $result
	While (($ip1<>"" and ($ip2<>"")))
		Call(_IpBuild(BitXOR(_IpParse($ip1) ,_IpParse($ip2)), $result))
	WEnd
	Return $result
EndFunc

;----------------------------------------------
;   IpGetByte
;----------------------------------------------
; get one byte from an ip address given its position
; example:
;   IpGetByte("192.168.1.1"; 1) returns 192
Func _IpGetByte($ip,$pos)
	Local $IpGetByte
	$pos=4-$pos
	For $i=0 to $pos
		$IpGetByte=_IpParse($ip)
	Next
	Return $IpGetByte
EndFunc

;----------------------------------------------
;   IpSetByte
;----------------------------------------------
; set one byte in an ip address given its position and value
; example:
;   IpSetByte("192.168.1.1"; 4; 20) returns "192.168.1.20"
Func _IpSetByte($ip,$pos,$newvalue)
	Local $result
	Local $byteval
	$i=4
	While ($ip<>"")
		$byteval=_IpParse($ip)
		If($i=$pos) Then $byteval=$newvalue
		Call(_IpBuild($byteval, $result))
		$i=$i-1
	WEnd
	Return $result
EndFunc



;----------------------------------------------
;   IpSubnetToBin
;----------------------------------------------
; Converts a subnet to binary
; This function is similar to IpStrToBin but ignores the host part of the address
; example:
;   IpSubnetToBin("1.2.3.4/24") returns 16909056
;   IpSubnetToBin("1.2.3.0/24") returns 16909056
Func _IpSubnetToBin($ip)
	Local $l
	Local $pos
	Local $v
	local $IpSubnetToBin
	$l=_IpSubnetParse($ip)
	$ip=$ip&"."
	$IpSubnetToBin =0
	While $ip<>""
		$pos=StringInStr($ip,".")
		$v=Number(StringLeft($ip,$pos-1))
		if($l<=0) Then
			$v=0
		ElseIf($l < 8) Then
			$v=BitAND($v , ((2 ^ $l - 1) * 2 ^ (8 - $l)))
		EndIf
		$IpSubnetToBin=$IpSubnetToBin*256+$v
		$ip=StringMid($ip,$pos+1)
		$l=$l-8
	WEnd
	Return $IpSubnetToBin
EndFunc

;----------------------------------------------
;   IpSubnetParse
;----------------------------------------------
; Get the mask len from a subnet and remove the mask from the address
; The ip parameter is modified and the subnet mask is removed
; example:
;   IpSubnetLen("192.168.1.1/24") returns 24 and ip is changed to "192.168.1.1"
;   IpSubnetLen("192.168.1.1 255.255.255.0") returns 24 and ip is changed to "192.168.1.1"
Func _IpSubnetParse(ByRef $ip)
	Local $p
	Local $IpSubnetParse
	$p=StringInStr($ip,"/")
	if($p=0) Then
		$p=StringInStr($ip," ")
		if($p=0) Then
			$IpSubnetParse =32
		Else
			$IpSubnetParse = _IpMaskLen(StringMid($ip,$p+1))
			$ip=StringLeft($ip,$p-1)
		EndIf
	Else
		$IpSubnetParse=Int(StringMid($ip,$p+1))
		$ip=StringLeft($ip,$p-1)
	EndIf
	Return $IpSubnetParse
EndFunc

;----------------------------------------------
;   IpMaskLen
;----------------------------------------------
; returns prefix length from a mask given by a string notation (xx.xx.xx.xx)
; example:
;   IpMaskLen("255.255.255.0") returns 24 which is the number of bits of the subnetwork prefix
Func _IpMaskLen($ipmaskstr)
	Local $IpMaskLen
	Local $notMask
	Local $zeroBits
	$notMask=2^32-1-_IpStrToBin($ipmaskstr)
	$zeroBits=0
	While $notMask<>0
		$notMask=Int($notMask/2)
		$zeroBits=$zeroBits+1
	WEnd
	$IpMaskLen=32-$zeroBits
	Return $IpMaskLen
EndFunc

;----------------------------------------------
;   IpSubnetIsInSubnet
;----------------------------------------------
; Returns TRUE if "subnet1" is in "subnet2"
; example:
;   IpSubnetIsInSubnet("192.168.1.35/30"; "192.168.1.32/29") returns TRUE
;   IpSubnetIsInSubnet("192.168.1.41/30"; "192.168.1.32/29") returns FALSE
;   IpSubnetIsInSubnet("192.168.1.35/28"; "192.168.1.32/29") returns FALSE
;   IpSubnetIsInSubnet("192.168.0.128 255.255.255.128"; "192.168.0.0 255.255.255.0") returns TRUE
Func _IpSubnetIsInSubnet($subnet1,$subnet2)
	Local $l1
	Local $l2
	Local $IpSubnetIsInSubnet=False
	$l1=_IpSubnetParse($subnet1)
	$l2=_IpSubnetParse($subnet2)
	if $l1< $l2 Then
		$IpSubnetIsInSubnet=False
	Else
		$IpSubnetIsInSubnet=_IpComp($subnet1,$subnet2,$l2)
	EndIf
	Return $IpSubnetIsInSubnet
EndFunc

;----------------------------------------------
;   IpComp
;----------------------------------------------
; Compares the first 'n' bits of ip1 and ip2
; example:
;   IpComp("10.0.0.0", "10.1.0.0", 9) returns TRUE
;   IpComp("10.0.0.0", "10.1.0.0", 16) returns FALSE
Func _IpComp($ip1,$ip2,$n)
	Local $pos1
	Local $pos2
	Local $mask
	Local $IpComp
	$IpComp=False
	$ip1=$ip1&"."
	$ip2=$ip2&"."
	While ($n>0) And($ip1<>"") And ($ip2<>"")
		$pos1=StringInStr($ip1,".")
		$pos2=StringInStr($ip2,".")
		if $n>=8 Then
			if $pos1<>$pos2 Then
				$IpComp=False
				Return $IpComp
			EndIf
			if StringLeft($ip1,$pos1)<>StringLeft($ip2,$pos2) Then
				$IpComp=False
				Return $IpComp
			EndIf
		Else
			$mask=(2 ^ $n - 1) * 2 ^ (8 - $n)
			$IpComp=(BitAND(Number(StringLeft($ip1,$pos1-1)) , $mask) = BitAND(Number(StringLeft($ip2,$pos2-1)) , $mask))
			Return $IpComp
		EndIf
		$n=$n-8
		$ip1=StringMid($ip1,$pos1+1)
		$ip2=StringMid($ip2,$pos2+1)
	WEnd
	$IpComp=True
	Return $IpComp
EndFunc

;----------------------------------------------
;   IpIsPrivate
;----------------------------------------------
; returns TRUE if "ip" is in one of the private IP address ranges
; example:
;   IpIsPrivate("192.168.1.35") returns TRUE
;   IpIsPrivate("209.85.148.104") returns FALSE
Func _IpIsPrivate($ip)
	Local $IpIsPrivate
	$IpIsPrivate=False
	$IpIsPrivate= (_IpIsInSubnet($ip, "10.0.0.0/8") Or _IpIsInSubnet($ip, "172.16.0.0/12") Or _IpIsInSubnet($ip, "192.168.0.0/16"))
	Return $IpIsPrivate
EndFunc

;----------------------------------------------
;   IpIsInSubnet
;----------------------------------------------
; Returns TRUE if "ip" is in "subnet"
;   IpIsInSubnet("192.168.1.41"; "192.168.1.32/29") returns FALSE
; example:
;   IpIsInSubnet("192.168.1.35"; "192.168.1.32/29") returns TRUE
;   IpIsInSubnet("192.168.1.35"; "192.168.1.32 255.255.255.248") returns TRUE
Func _IpIsInSubnet($ip,$subnet)
	Local $l
	Local $IpIsInSubnet
	$l=_IpSubnetParse($subnet)
	$IpIsInSubnet=_IpComp($ip, $subnet, $l)
	Return $IpIsInSubnet
EndFunc

;----------------------------------------------
;   IpParse
;----------------------------------------------
; Parses an IP address by iteration from right to left
; Removes one byte from the right of "ip" and returns it as an integer
; example:
;   if ip="192.168.1.32"
;   IpParse(ip) returns 32 and ip="192.168.1" when the function returns
func _IpParse(ByRef $ip)
	Local $pos
	Local $IpParse
	$pos=StringInStr($ip,".",0,-1)
	if $pos=0 Then
		$IpParse=Number($ip)
		$ip=""
	Else
		$IpParse=Number(StringMid($ip,$pos+1))
		$ip=StringLeft($ip,$pos-1)
	EndIf
	Return $IpParse
EndFunc

;----------------------------------------------
;   IpBuild
;----------------------------------------------
; Builds an IP address by iteration from right to left
; Adds "ip_byte" to the left the "ip"
; If "ip_byte" is greater than 255, only the lower 8 bits are added to "ip"
; and the remaining bits are returned to be used on the next IpBuild call
; example 1:
;   if ip="168.1.1"
;   IpBuild(192, ip) returns 0 and ip="192.168.1.1"
; example 2:
;   if ip="1"
;   IpBuild(258, ip) returns 1 and ip="2.1"
Func _IpBuild($ip_byte, ByRef $ip)
	if $ip<>"" Then $ip="."&$ip
	$ip=StringFormat(BitAND($ip_byte,255))&$ip
	Return Int($ip_byte/256)
EndFunc

;----------------------------------------------
;   IpSortArray
;----------------------------------------------
; this function must be used in an array formula
; 'ip_array' is a single column array containing ip addresses
; the return value is also a array of the same size containing the same
; addresses sorted in ascending or descending order
; 'descending' is an optional parameter, if set to True the adresses are
; sorted in descending order
Func _IpSortArray($ip_array,$descending=False)
	Local $s
	Local $t
	$t=0
	$s=UBound($ip_array)
	local $list[$s]
	Local $result[$s]
	for $i = 0 to $s-1
		If($ip_array[$i]<>0) Then
			$list[$i]=_IpStrToBin($ip_array[$i])
			$t=$t+1
		EndIf
	Next
	_ArraySort($list,$descending)
	for $i=0 to $s-1
		$result[$i]=_IpBinToStr($list[$i])
	Next
	Return $result
EndFunc

;----------------------------------------------
;   IpSubnetMatch
;----------------------------------------------
; Tries to match an IP address or a subnet against a list of subnets in the
; left-most column of table_array and returns the row number
; 'ip' is the value to search for in the subnets in the first column of
;      the table_array
; 'table_array' is one or more columns of data
; 'fast' indicates the search mode : BestMatch or Fast mode
; fast = 0 (default value)
;    This will work on any subnet list. If the search value matches more
;    than one subnet, the smallest subnet will be returned (best match)
; fast = 1
;    The subnet list MUST be sorted in ascending order and MUST NOT contain
;    overlapping subnets. This mode performs a dichotomic search and runs
;    much faster with large subnet lists.
; The function returns 0 if the IP address is not matched.
Func _IpSubnetMatch($ip,$table_array,$fast=False) ; this function not complete when fast=ture
	Local $i
	local $IpSubnetMatch=0
	if $fast Then
		Local $a
		Local $b
		local $ip_bin
		$a=0
		$b=UBound($table_array)
		$ip_bin= _IpSubnetToBin($ip)
		Do
			$i=Round(($a+$b+0.5)/2)
			MsgBox("","",$i)
			if $ip_bin<_IpSubnetToBin($table_array[$i]) Then
				$b=$i-1
			Else
				$a=$i
			EndIf
			MsgBox("","","a="&$a)
			MsgBox("","","b="&$b)
		Until $a>=$b
		if _IpSubnetIsInSubnet($ip,$table_array[$a]) Then
			$IpSubnetMatch=$a
		EndIf
	Else
		Local $previousMatchLen
		Local $searchLen
		Local $subnet
		Local $subnetLen
		$searchLen = _IpSubnetParse($ip)
		$previousMatchLen=0
		for $i=0 to UBound($table_array)-1
			$subnet=$table_array[$i]
			$subnetLen=_IpSubnetParse($subnet)
			if $subnetLen >= $previousMatchLen Then
				if $searchLen>=$subnetLen Then
					if _IpComp($ip,$subnet,$subnetLen) Then
						$previousMatchLen=$subnetLen
						$IpSubnetMatch=$i
					EndIf
				EndIf
			EndIf
		Next
	EndIf
	Return $IpSubnetMatch
EndFunc

;----------------------------------------------
;   IpSubnetSortArray
;----------------------------------------------
; this function must be used in an array formula
; 'ip_array' is a single column array containing ip subnets in "prefix/len"
; or "prefix mask" notation
; the return value is also an array of the same size containing the same
; subnets sorted in ascending or descending order
; 'descending' is an optional parameter, if set to True the subnets are
; sorted in descending order
Func _IpSubnetSortArray($ip_array,$descending =False)
	Local $s
	Local $t
	$t=0
	$s=UBound($ip_array)
	Local $list[$s]
	for $i = 0 to $s-1
		if ($ip_array[$i]<>0) Then
			$t=$t+1
			$list[$i]=$ip_array[$i]
		EndIf
	Next
	For $i = $t - 1 To 0 Step -1
        For $j = 0 To $i -1
            local $m
			Local $n
            $m = _IpStrToBin($list[$j])
			MsgBox("","",$j + 1)
            $n = _IpStrToBin($list[$j + 1])
            If (BitXOR((($m > $n) Or (($m = $n) And (_IpMaskBin($list[$j]) < _IpMaskBin($list[$j + 1])))), $descending)) Then
                local $swap
                $swap = $list[$j]
                $list[$j] = $list[$j + 1]
                $list[$j + 1] = $swap
            EndIf
        Next
    Next
	Return $list
EndFunc

;----------------------------------------------
;   IpMaskBin
;----------------------------------------------
; returns binary IP mask from an address with / notation (xx.xx.xx.xx/yy)
; example:
;   IpMask("192.168.1.1/24") returns 4294967040 which is the binary
;   representation of "255.255.255.0"
Func _IpMaskBin($ip)
	Local $bits
	local $IpMaskBin
	$bits=_IpSubnetLen($ip)
	$IpMaskBin=(2 ^ $bits - 1) * 2 ^ (32 - $bits)
	Return $IpMaskBin
EndFunc

;----------------------------------------------
;   IpSubnetLen
;----------------------------------------------
; get the mask len from a subnet
; example:
;   IpSubnetLen("192.168.1.1/24") returns 24
;   IpSubnetLen("192.168.1.1 255.255.255.0") returns 24
Func _IpSubnetLen($ip)
	Local $p
	Local $IpSubnetLen=0
	$p=StringInStr($ip,"/")
	if ($p=0) Then
		$p=StringInStr($ip," ")
		if($p=0) Then
			$IpSubnetLen=32
		Else
			$IpSubnetLen=_IpMaskLen(StringMid($ip,$p+1))
		EndIf
	Else
		$IpSubnetLen=Number(StringMid($ip,$p+1))
	EndIf
	Return $IpSubnetLen
EndFunc

;----------------------------------------------
;   IpWildMask
;----------------------------------------------
; returns an IP Wildcard (inverse) mask from a subnet
; both notations are accepted
; example:
;   IpWildMask("192.168.1.1/24") returns "0.0.0.255"
;   IpWildMask("192.168.1.1 255.255.255.0") returns "0.0.0.255"
Func _IpWildMask($ip)
	Return _IpBinToStr(((2 ^ 32) - 1) - _IpMaskBin($ip))
EndFunc

;----------------------------------------------
;   IpInvertMask
;----------------------------------------------
; returns an IP Wildcard (inverse) mask from a subnet mask
; or a subnet mask from a wildcard mask
; example:
;   IpInvertMask("255.255.255.0") returns "0.0.0.255"
;   IpInvertMask("0.0.0.255") returns "255.255.255.0"
Func _IpInvertMask($mask)
	Return _IpBinToStr(((2 ^ 32) - 1) - _IpStrToBin($mask))
EndFunc

;----------------------------------------------
;   IpFindOverlappingSubnets
;----------------------------------------------
; this function must be used in an array formula
; it will find in the list of subnets which subnets overlap
; 'SubnetsArray' is single column array containing a list of subnets, the
; list may be sorted or not
; the return value is also a array of the same size
; if the subnet on line x is included in a larger subnet from another line,
; this function returns an array in which line x contains the value of the
; larger subnet
; if the subnet on line x is distinct from any other subnet in the array,
; then this function returns on line x an empty cell
; if there are no overlapping subnets in the input array, the returned array
; is empty
Func _IpFindOverlappingSubnets($subnets_array)
	Local $result[UBound($subnets_array)]
	For $i=0 to UBound($subnets_array)-1
		$result[$i]=""
		For $j= 0 to UBound($subnets_array)-1
			If($i<>$j) And _IpSubnetIsInSubnet($subnets_array[$i], $subnets_array[$j]) Then
				$result[$i]=$subnets_array[$j]
				ExitLoop
			EndIf
		Next
	Next
	Return $result
EndFunc

;----------------------------------------------
;   IpSubnetSize
;----------------------------------------------
; returns the number of addresses in a subnet
; example:
;   IpSubnetSize("192.168.1.32/29") returns 8
;   IpSubnetSize("192.168.1.0 255.255.255.0") returns 256
Func _IpSubnetSize($subnet)
	Return 2 ^ (32 - _IpSubnetLen($subnet))
EndFunc

;----------------------------------------------
;   IpClearHostBits
;----------------------------------------------
; set to zero the bits in the host part of an address
; example:
;   IpClearHostBits("192.168.1.1/24") returns "192.168.1.0/24"
;   IpClearHostBits("192.168.1.193 255.255.255.128") returns "192.168.1.128 255.255.255.128"
Func _IpClearHostBits($net)
	Local $ip
	Local $result
	$ip=_IpWithoutMask($net)
	$result=_IpAnd($ip, _IpMask($net)) & StringMid($net, StringLen($ip)+ 1)
	Return $result
EndFunc

;----------------------------------------------
;   IpMask
;----------------------------------------------
; returns an IP netmask from a subnet
; both notations are accepted
; example:
;   IpMask("192.168.1.1/24") returns "255.255.255.0"
;   IpMask("192.168.1.1 255.255.255.0") returns "255.255.255.0"
Func _IpMask($ip)
	Local $result
	$result=_IpBinToStr(_IpMaskBin($ip))
	Return $result
EndFunc

;----------------------------------------------
;   IpWithoutMask
;----------------------------------------------
; removes the netmask notation at the end of the IP
; example:
;   IpWithoutMask("192.168.1.1/24") returns "192.168.1.1"
;   IpWithoutMask("192.168.1.1 255.255.255.0") returns "192.168.1.1"
Func _IpWithoutMask($ip)
	Local $p
	Local $result
	$p=StringInStr($ip,"/")
	if ($p=0) Then
		$p=StringInStr($ip," ")
	EndIf
	if ($p=0) Then
		$result=$ip
	Else
		$result=StringLeft($ip,$p-1)
	EndIf
	Return $result
EndFunc

;----------------------------------------------
;   IpDiff
;----------------------------------------------
; difference between 2 IP addresses
; example:
;   IpDiff("192.168.1.7"; "192.168.1.1") returns 6
Func _IpDiff($ip1,$ip2)
	Local $IpDiff
	Local $mult
	$mult =1
	$IpDiff=0
	While(($ip1<>"") or $ip2<>"")
		$IpDiff=$IpDiff+$mult*(_IpParse($ip1)-_IpParse($ip2))
		$mult=$mult*256
	WEnd
	Return $IpDiff
EndFunc

;----------------------------------------------
;   IpRangeToCIDR
;----------------------------------------------
; returns a network or a list of networks given the first and the
; last address of an IP range
; if this function is used in a array formula, it may return more
; than one network
; example:
;   IpRangeToCIDR("10.0.0.1","10.0.0.254") returns 10.0.0.0/24
;   IpRangeToCIDR("10.0.0.1","10.0.1.63") returns the array : 10.0.0.0/24 10.0.1.0/26
; note:
;   10.0.0.0 or 10.0.0.1 as the first address returns the same result
;   10.0.0.254 or 10.0.0.255 (broadcast) as the last address returns the same result
Func _IpRangeToCIDR($firstAddr,$lastAddr)
    $firstAddr = _IpAnd($firstAddr, "255.255.255.254") ; set the last bit to zero
    $lastAddr = _IpOr($lastAddr, "0.0.0.1") ; set the last bit to one
	Local $list[0]
	local $n=0
	Local $IpRangeToCIDR
	Do
		$l=0
		Do; find the largest network which first address is firstAddr and which last address is not higher than lastAddr
          ; build a network of length l
          ; if it does not comply the above conditions, try with a smaller network
            $l = $l + 1
            $net = $firstAddr & "/" & $l
            $ip1 = _IpAnd($firstAddr, _IpMask($net)) ; first @ of this network
            $ip2 = _IpOr($firstAddr, _IpWildMask($net)) ; last @ of this network
            $net = $ip1 & "/" & $l ; rebuild the network with the first address
            $diff = _IpDiff($ip2, $lastAddr) ; difference between the last @ of this network and the lastAddr we need to reach
		Until Not(($l < 32) And (($ip1 <> $firstAddr) Or ($diff > 0)))
		$n = $n + 1
        ReDim $list[$n]
        $list[$n-1] = $net
        $firstAddr = _IpAdd($ip2, 1)
    Until not($diff < 0) ; if we haven't reached the lastAddr, loop to build another network

	Local $resultArray[0][1]
    ReDim $resultArray[$n][1]
	For $i = 0 To $n -1
        $resultArray[$i][0] = $list[$i]
    Next
    $IpRangeToCIDR = $resultArray
	Return $IpRangeToCIDR
EndFunc

;----------------------------------------------
;   IpParseRoute
;----------------------------------------------
; this function is used by IpSubnetSortJoinArray to extract the subnet
; and next hop in route
; the supported formats are
; 10.0.0.0 255.255.255.0 1.2.3.4
; 10.0.0.0/24 1.2.3.4
; the next hop can be any character sequence, and not only an IP
Func _IpParseRoute($route, ByRef $nexthop)
	$slash = StringInStr($route, "/")
    $sp = StringInStr($route, " ")
    If (($slash = 0) And ($sp > 0)) Then
        $temp = StringMid($route, $sp + 1)
        $sp = StringInStr($route, " ",0,1,$sp + 1)
    EndIf
    If ($sp = 0) Then
        $nexthop = ""
		Return $route
    Else
        $nexthop = StringMid($route, $sp + 1)
		Return StringLeft($route, $sp - 1)
    EndIf
EndFunc


