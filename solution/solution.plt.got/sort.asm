
sort：     文件格式 elf64-x86-64


Disassembly of section .init:

0000000000400480 <_init>:
  400480:	48 83 ec 08          	sub    $0x8,%rsp
  400484:	48 8b 05 6d 1b 20 00 	mov    0x201b6d(%rip),%rax        # 601ff8 <__gmon_start__>
  40048b:	48 85 c0             	test   %rax,%rax
  40048e:	74 02                	je     400492 <_init+0x12>
  400490:	ff d0                	callq  *%rax
  400492:	48 83 c4 08          	add    $0x8,%rsp
  400496:	c3                   	retq   

Disassembly of section .plt:

00000000004004a0 <.plt>:
  4004a0:	ff 35 62 1b 20 00    	pushq  0x201b62(%rip)        # 602008 <_GLOBAL_OFFSET_TABLE_+0x8>
  4004a6:	ff 25 64 1b 20 00    	jmpq   *0x201b64(%rip)        # 602010 <_GLOBAL_OFFSET_TABLE_+0x10>
  4004ac:	0f 1f 40 00          	nopl   0x0(%rax)

00000000004004b0 <putchar@plt>:
  4004b0:	ff 25 62 1b 20 00    	jmpq   *0x201b62(%rip)        # 602018 <putchar@GLIBC_2.2.5>
  4004b6:	68 00 00 00 00       	pushq  $0x0
  4004bb:	e9 e0 ff ff ff       	jmpq   4004a0 <.plt>

00000000004004c0 <strlen@plt>:
  4004c0:	ff 25 5a 1b 20 00    	jmpq   *0x201b5a(%rip)        # 602020 <strlen@GLIBC_2.2.5>
  4004c6:	68 01 00 00 00       	pushq  $0x1
  4004cb:	e9 d0 ff ff ff       	jmpq   4004a0 <.plt>

00000000004004d0 <printf@plt>:
  4004d0:	ff 25 52 1b 20 00    	jmpq   *0x201b52(%rip)        # 602028 <printf@GLIBC_2.2.5>
  4004d6:	68 02 00 00 00       	pushq  $0x2
  4004db:	e9 c0 ff ff ff       	jmpq   4004a0 <.plt>

Disassembly of section .plt.got:

00000000004004e0 <puts@plt>:
  4004e0:	ff 25 02 1b 20 00    	jmpq   *0x201b02(%rip)        # 601fe8 <puts@GLIBC_2.2.5>
  4004e6:	66 90                	xchg   %ax,%ax

Disassembly of section .text:

00000000004004f0 <_start>:
  4004f0:	31 ed                	xor    %ebp,%ebp
  4004f2:	49 89 d1             	mov    %rdx,%r9
  4004f5:	5e                   	pop    %rsi
  4004f6:	48 89 e2             	mov    %rsp,%rdx
  4004f9:	48 83 e4 f0          	and    $0xfffffffffffffff0,%rsp
  4004fd:	50                   	push   %rax
  4004fe:	54                   	push   %rsp
  4004ff:	49 c7 c0 30 0d 40 00 	mov    $0x400d30,%r8
  400506:	48 c7 c1 c0 0c 40 00 	mov    $0x400cc0,%rcx
  40050d:	48 c7 c7 d7 05 40 00 	mov    $0x4005d7,%rdi
  400514:	ff 15 d6 1a 20 00    	callq  *0x201ad6(%rip)        # 601ff0 <__libc_start_main@GLIBC_2.2.5>
  40051a:	f4                   	hlt    
  40051b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

0000000000400520 <_dl_relocate_static_pie>:
  400520:	f3 c3                	repz retq 
  400522:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  400529:	00 00 00 
  40052c:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000400530 <deregister_tm_clones>:
  400530:	55                   	push   %rbp
  400531:	b8 40 20 60 00       	mov    $0x602040,%eax
  400536:	48 3d 40 20 60 00    	cmp    $0x602040,%rax
  40053c:	48 89 e5             	mov    %rsp,%rbp
  40053f:	74 17                	je     400558 <deregister_tm_clones+0x28>
  400541:	b8 00 00 00 00       	mov    $0x0,%eax
  400546:	48 85 c0             	test   %rax,%rax
  400549:	74 0d                	je     400558 <deregister_tm_clones+0x28>
  40054b:	5d                   	pop    %rbp
  40054c:	bf 40 20 60 00       	mov    $0x602040,%edi
  400551:	ff e0                	jmpq   *%rax
  400553:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  400558:	5d                   	pop    %rbp
  400559:	c3                   	retq   
  40055a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)

0000000000400560 <register_tm_clones>:
  400560:	be 40 20 60 00       	mov    $0x602040,%esi
  400565:	55                   	push   %rbp
  400566:	48 81 ee 40 20 60 00 	sub    $0x602040,%rsi
  40056d:	48 89 e5             	mov    %rsp,%rbp
  400570:	48 c1 fe 03          	sar    $0x3,%rsi
  400574:	48 89 f0             	mov    %rsi,%rax
  400577:	48 c1 e8 3f          	shr    $0x3f,%rax
  40057b:	48 01 c6             	add    %rax,%rsi
  40057e:	48 d1 fe             	sar    %rsi
  400581:	74 15                	je     400598 <register_tm_clones+0x38>
  400583:	b8 00 00 00 00       	mov    $0x0,%eax
  400588:	48 85 c0             	test   %rax,%rax
  40058b:	74 0b                	je     400598 <register_tm_clones+0x38>
  40058d:	5d                   	pop    %rbp
  40058e:	bf 40 20 60 00       	mov    $0x602040,%edi
  400593:	ff e0                	jmpq   *%rax
  400595:	0f 1f 00             	nopl   (%rax)
  400598:	5d                   	pop    %rbp
  400599:	c3                   	retq   
  40059a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)

00000000004005a0 <__do_global_dtors_aux>:
  4005a0:	80 3d 99 1a 20 00 00 	cmpb   $0x0,0x201a99(%rip)        # 602040 <__TMC_END__>
  4005a7:	75 17                	jne    4005c0 <__do_global_dtors_aux+0x20>
  4005a9:	55                   	push   %rbp
  4005aa:	48 89 e5             	mov    %rsp,%rbp
  4005ad:	e8 7e ff ff ff       	callq  400530 <deregister_tm_clones>
  4005b2:	c6 05 87 1a 20 00 01 	movb   $0x1,0x201a87(%rip)        # 602040 <__TMC_END__>
  4005b9:	5d                   	pop    %rbp
  4005ba:	c3                   	retq   
  4005bb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  4005c0:	f3 c3                	repz retq 
  4005c2:	0f 1f 40 00          	nopl   0x0(%rax)
  4005c6:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  4005cd:	00 00 00 

00000000004005d0 <frame_dummy>:
  4005d0:	55                   	push   %rbp
  4005d1:	48 89 e5             	mov    %rsp,%rbp
  4005d4:	5d                   	pop    %rbp
  4005d5:	eb 89                	jmp    400560 <register_tm_clones>

00000000004005d7 <main>:
  4005d7:	55                   	push   %rbp
  4005d8:	48 89 e5             	mov    %rsp,%rbp
  4005db:	48 81 ec a0 00 00 00 	sub    $0xa0,%rsp
  4005e2:	89 bd 6c ff ff ff    	mov    %edi,-0x94(%rbp)
  4005e8:	48 89 b5 60 ff ff ff 	mov    %rsi,-0xa0(%rbp)
  4005ef:	c7 45 cc 02 00 00 00 	movl   $0x2,-0x34(%rbp)
  4005f6:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%rbp)
  4005fd:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%rbp)
  400604:	c7 45 d8 06 00 00 00 	movl   $0x6,-0x28(%rbp)
  40060b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%rbp)
  400612:	c7 45 e0 05 00 00 00 	movl   $0x5,-0x20(%rbp)
  400619:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%rbp)
  400620:	c7 45 e8 08 00 00 00 	movl   $0x8,-0x18(%rbp)
  400627:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  40062e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%rbp)
  400635:	48 c7 45 f0 00 00 00 	movq   $0x0,-0x10(%rbp)
  40063c:	00 
  40063d:	48 8d 05 c0 03 00 00 	lea    0x3c0(%rip),%rax        # 400a04 <down>
  400644:	48 89 85 78 ff ff ff 	mov    %rax,-0x88(%rbp)
  40064b:	48 8d 05 b3 01 00 00 	lea    0x1b3(%rip),%rax        # 400805 <up>
  400652:	48 89 45 80          	mov    %rax,-0x80(%rbp)
  400656:	48 8d 05 a7 02 00 00 	lea    0x2a7(%rip),%rax        # 400904 <up_fl>
  40065d:	48 89 45 88          	mov    %rax,-0x78(%rbp)
  400661:	48 8d 05 9b 04 00 00 	lea    0x49b(%rip),%rax        # 400b03 <reverse>
  400668:	48 89 45 90          	mov    %rax,-0x70(%rbp)
  40066c:	48 8d 05 2f 05 00 00 	lea    0x52f(%rip),%rax        # 400ba2 <magic>
  400673:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  400677:	48 8d 05 86 03 00 00 	lea    0x386(%rip),%rax        # 400a04 <down>
  40067e:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
  400682:	48 8d 05 7c 01 00 00 	lea    0x17c(%rip),%rax        # 400805 <up>
  400689:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
  40068d:	48 8d 05 70 02 00 00 	lea    0x270(%rip),%rax        # 400904 <up_fl>
  400694:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  400698:	48 8d 05 64 04 00 00 	lea    0x464(%rip),%rax        # 400b03 <reverse>
  40069f:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  4006a3:	48 8d 05 f8 04 00 00 	lea    0x4f8(%rip),%rax        # 400ba2 <magic>
  4006aa:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  4006ae:	48 8d 05 e0 05 00 00 	lea    0x5e0(%rip),%rax        # 400c95 <fake_puts>
  4006b5:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  4006b9:	8b 95 6c ff ff ff    	mov    -0x94(%rbp),%edx
  4006bf:	89 d0                	mov    %edx,%eax
  4006c1:	c1 e0 02             	shl    $0x2,%eax
  4006c4:	01 d0                	add    %edx,%eax
  4006c6:	01 c0                	add    %eax,%eax
  4006c8:	83 f8 14             	cmp    $0x14,%eax
  4006cb:	74 25                	je     4006f2 <main+0x11b>
  4006cd:	83 f8 1e             	cmp    $0x1e,%eax
  4006d0:	74 3b                	je     40070d <main+0x136>
  4006d2:	83 f8 0a             	cmp    $0xa,%eax
  4006d5:	75 51                	jne    400728 <main+0x151>
  4006d7:	48 8d 05 27 01 00 00 	lea    0x127(%rip),%rax        # 400805 <up>
  4006de:	48 89 05 63 19 20 00 	mov    %rax,0x201963(%rip)        # 602048 <fp.2713>
  4006e5:	48 8b 05 fc 18 20 00 	mov    0x2018fc(%rip),%rax        # 601fe8 <puts@GLIBC_2.2.5>
  4006ec:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  4006f0:	eb 4f                	jmp    400741 <main+0x16a>
  4006f2:	48 8d 05 0b 03 00 00 	lea    0x30b(%rip),%rax        # 400a04 <down>
  4006f9:	48 89 05 48 19 20 00 	mov    %rax,0x201948(%rip)        # 602048 <fp.2713>
  400700:	48 8d 05 8e 05 00 00 	lea    0x58e(%rip),%rax        # 400c95 <fake_puts>
  400707:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  40070b:	eb 34                	jmp    400741 <main+0x16a>
  40070d:	48 8d 05 ef 03 00 00 	lea    0x3ef(%rip),%rax        # 400b03 <reverse>
  400714:	48 89 05 2d 19 20 00 	mov    %rax,0x20192d(%rip)        # 602048 <fp.2713>
  40071b:	48 8b 05 c6 18 20 00 	mov    0x2018c6(%rip),%rax        # 601fe8 <puts@GLIBC_2.2.5>
  400722:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  400726:	eb 19                	jmp    400741 <main+0x16a>
  400728:	48 8d 05 d6 00 00 00 	lea    0xd6(%rip),%rax        # 400805 <up>
  40072f:	48 89 05 12 19 20 00 	mov    %rax,0x201912(%rip)        # 602048 <fp.2713>
  400736:	48 8d 05 58 05 00 00 	lea    0x558(%rip),%rax        # 400c95 <fake_puts>
  40073d:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  400741:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
  400746:	74 10                	je     400758 <main+0x181>
  400748:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  40074c:	48 8d 3d f1 05 00 00 	lea    0x5f1(%rip),%rdi        # 400d44 <_IO_stdin_used+0x4>
  400753:	ff d0                	callq  *%rax
  400755:	89 45 ec             	mov    %eax,-0x14(%rbp)
  400758:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  40075f:	eb 18                	jmp    400779 <main+0x1a2>
  400761:	48 8b 15 e0 18 20 00 	mov    0x2018e0(%rip),%rdx        # 602048 <fp.2713>
  400768:	8b 45 fc             	mov    -0x4(%rbp),%eax
  40076b:	48 98                	cltq   
  40076d:	48 89 94 c5 78 ff ff 	mov    %rdx,-0x88(%rbp,%rax,8)
  400774:	ff 
  400775:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  400779:	83 7d fc 09          	cmpl   $0x9,-0x4(%rbp)
  40077d:	7e e2                	jle    400761 <main+0x18a>
  40077f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  400786:	eb 1f                	jmp    4007a7 <main+0x1d0>
  400788:	8b 45 fc             	mov    -0x4(%rbp),%eax
  40078b:	48 98                	cltq   
  40078d:	48 8b 84 c5 78 ff ff 	mov    -0x88(%rbp,%rax,8),%rax
  400794:	ff 
  400795:	48 8d 55 cc          	lea    -0x34(%rbp),%rdx
  400799:	48 89 d6             	mov    %rdx,%rsi
  40079c:	bf 08 00 00 00       	mov    $0x8,%edi
  4007a1:	ff d0                	callq  *%rax
  4007a3:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  4007a7:	83 7d fc 09          	cmpl   $0x9,-0x4(%rbp)
  4007ab:	7e db                	jle    400788 <main+0x1b1>
  4007ad:	48 8b 15 94 18 20 00 	mov    0x201894(%rip),%rdx        # 602048 <fp.2713>
  4007b4:	48 8d 45 cc          	lea    -0x34(%rbp),%rax
  4007b8:	48 89 c6             	mov    %rax,%rsi
  4007bb:	bf 08 00 00 00       	mov    $0x8,%edi
  4007c0:	e8 3b 04 00 00       	callq  400c00 <sort_and_display>
  4007c5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  4007cc:	eb 20                	jmp    4007ee <main+0x217>
  4007ce:	8b 45 fc             	mov    -0x4(%rbp),%eax
  4007d1:	48 98                	cltq   
  4007d3:	8b 44 85 cc          	mov    -0x34(%rbp,%rax,4),%eax
  4007d7:	89 c6                	mov    %eax,%esi
  4007d9:	48 8d 3d 66 05 00 00 	lea    0x566(%rip),%rdi        # 400d46 <_IO_stdin_used+0x6>
  4007e0:	b8 00 00 00 00       	mov    $0x0,%eax
  4007e5:	e8 e6 fc ff ff       	callq  4004d0 <printf@plt>
  4007ea:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  4007ee:	83 7d fc 07          	cmpl   $0x7,-0x4(%rbp)
  4007f2:	7e da                	jle    4007ce <main+0x1f7>
  4007f4:	bf 0a 00 00 00       	mov    $0xa,%edi
  4007f9:	e8 b2 fc ff ff       	callq  4004b0 <putchar@plt>
  4007fe:	b8 01 00 00 00       	mov    $0x1,%eax
  400803:	c9                   	leaveq 
  400804:	c3                   	retq   

0000000000400805 <up>:
  400805:	55                   	push   %rbp
  400806:	48 89 e5             	mov    %rsp,%rbp
  400809:	89 7d ec             	mov    %edi,-0x14(%rbp)
  40080c:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  400810:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  400817:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
  40081e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
  400825:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  40082c:	e9 c1 00 00 00       	jmpq   4008f2 <up+0xed>
  400831:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
  400838:	e9 9f 00 00 00       	jmpq   4008dc <up+0xd7>
  40083d:	8b 45 f8             	mov    -0x8(%rbp),%eax
  400840:	48 98                	cltq   
  400842:	48 8d 14 85 00 00 00 	lea    0x0(,%rax,4),%rdx
  400849:	00 
  40084a:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  40084e:	48 01 d0             	add    %rdx,%rax
  400851:	8b 10                	mov    (%rax),%edx
  400853:	8b 45 f8             	mov    -0x8(%rbp),%eax
  400856:	48 98                	cltq   
  400858:	48 83 c0 01          	add    $0x1,%rax
  40085c:	48 8d 0c 85 00 00 00 	lea    0x0(,%rax,4),%rcx
  400863:	00 
  400864:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  400868:	48 01 c8             	add    %rcx,%rax
  40086b:	8b 00                	mov    (%rax),%eax
  40086d:	39 c2                	cmp    %eax,%edx
  40086f:	7e 67                	jle    4008d8 <up+0xd3>
  400871:	8b 45 f8             	mov    -0x8(%rbp),%eax
  400874:	48 98                	cltq   
  400876:	48 8d 14 85 00 00 00 	lea    0x0(,%rax,4),%rdx
  40087d:	00 
  40087e:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  400882:	48 01 d0             	add    %rdx,%rax
  400885:	8b 00                	mov    (%rax),%eax
  400887:	89 45 f4             	mov    %eax,-0xc(%rbp)
  40088a:	8b 45 f8             	mov    -0x8(%rbp),%eax
  40088d:	48 98                	cltq   
  40088f:	48 83 c0 01          	add    $0x1,%rax
  400893:	48 8d 14 85 00 00 00 	lea    0x0(,%rax,4),%rdx
  40089a:	00 
  40089b:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  40089f:	48 01 d0             	add    %rdx,%rax
  4008a2:	8b 55 f8             	mov    -0x8(%rbp),%edx
  4008a5:	48 63 d2             	movslq %edx,%rdx
  4008a8:	48 8d 0c 95 00 00 00 	lea    0x0(,%rdx,4),%rcx
  4008af:	00 
  4008b0:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  4008b4:	48 01 ca             	add    %rcx,%rdx
  4008b7:	8b 00                	mov    (%rax),%eax
  4008b9:	89 02                	mov    %eax,(%rdx)
  4008bb:	8b 45 f8             	mov    -0x8(%rbp),%eax
  4008be:	48 98                	cltq   
  4008c0:	48 83 c0 01          	add    $0x1,%rax
  4008c4:	48 8d 14 85 00 00 00 	lea    0x0(,%rax,4),%rdx
  4008cb:	00 
  4008cc:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  4008d0:	48 01 c2             	add    %rax,%rdx
  4008d3:	8b 45 f4             	mov    -0xc(%rbp),%eax
  4008d6:	89 02                	mov    %eax,(%rdx)
  4008d8:	83 45 f8 01          	addl   $0x1,-0x8(%rbp)
  4008dc:	8b 45 ec             	mov    -0x14(%rbp),%eax
  4008df:	2b 45 fc             	sub    -0x4(%rbp),%eax
  4008e2:	83 e8 01             	sub    $0x1,%eax
  4008e5:	39 45 f8             	cmp    %eax,-0x8(%rbp)
  4008e8:	0f 8c 4f ff ff ff    	jl     40083d <up+0x38>
  4008ee:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  4008f2:	8b 45 ec             	mov    -0x14(%rbp),%eax
  4008f5:	83 e8 01             	sub    $0x1,%eax
  4008f8:	39 45 fc             	cmp    %eax,-0x4(%rbp)
  4008fb:	0f 8c 30 ff ff ff    	jl     400831 <up+0x2c>
  400901:	90                   	nop
  400902:	5d                   	pop    %rbp
  400903:	c3                   	retq   

0000000000400904 <up_fl>:
  400904:	55                   	push   %rbp
  400905:	48 89 e5             	mov    %rsp,%rbp
  400908:	89 7d ec             	mov    %edi,-0x14(%rbp)
  40090b:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  40090f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  400916:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
  40091d:	d9 ee                	fldz   
  40091f:	dd 5d f0             	fstpl  -0x10(%rbp)
  400922:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  400929:	e9 c4 00 00 00       	jmpq   4009f2 <up_fl+0xee>
  40092e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
  400935:	e9 a2 00 00 00       	jmpq   4009dc <up_fl+0xd8>
  40093a:	8b 45 f8             	mov    -0x8(%rbp),%eax
  40093d:	48 98                	cltq   
  40093f:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  400946:	00 
  400947:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  40094b:	48 01 d0             	add    %rdx,%rax
  40094e:	dd 00                	fldl   (%rax)
  400950:	8b 45 f8             	mov    -0x8(%rbp),%eax
  400953:	48 98                	cltq   
  400955:	48 83 c0 01          	add    $0x1,%rax
  400959:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  400960:	00 
  400961:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  400965:	48 01 d0             	add    %rdx,%rax
  400968:	dd 00                	fldl   (%rax)
  40096a:	d9 c9                	fxch   %st(1)
  40096c:	df e9                	fucomip %st(1),%st
  40096e:	dd d8                	fstp   %st(0)
  400970:	76 66                	jbe    4009d8 <up_fl+0xd4>
  400972:	8b 45 f8             	mov    -0x8(%rbp),%eax
  400975:	48 98                	cltq   
  400977:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  40097e:	00 
  40097f:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  400983:	48 01 d0             	add    %rdx,%rax
  400986:	dd 00                	fldl   (%rax)
  400988:	dd 5d f0             	fstpl  -0x10(%rbp)
  40098b:	8b 45 f8             	mov    -0x8(%rbp),%eax
  40098e:	48 98                	cltq   
  400990:	48 83 c0 01          	add    $0x1,%rax
  400994:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  40099b:	00 
  40099c:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  4009a0:	48 01 c2             	add    %rax,%rdx
  4009a3:	8b 45 f8             	mov    -0x8(%rbp),%eax
  4009a6:	48 98                	cltq   
  4009a8:	48 8d 0c c5 00 00 00 	lea    0x0(,%rax,8),%rcx
  4009af:	00 
  4009b0:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  4009b4:	48 01 c8             	add    %rcx,%rax
  4009b7:	dd 02                	fldl   (%rdx)
  4009b9:	dd 18                	fstpl  (%rax)
  4009bb:	8b 45 f8             	mov    -0x8(%rbp),%eax
  4009be:	48 98                	cltq   
  4009c0:	48 83 c0 01          	add    $0x1,%rax
  4009c4:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  4009cb:	00 
  4009cc:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  4009d0:	48 01 d0             	add    %rdx,%rax
  4009d3:	dd 45 f0             	fldl   -0x10(%rbp)
  4009d6:	dd 18                	fstpl  (%rax)
  4009d8:	83 45 f8 01          	addl   $0x1,-0x8(%rbp)
  4009dc:	8b 45 ec             	mov    -0x14(%rbp),%eax
  4009df:	2b 45 fc             	sub    -0x4(%rbp),%eax
  4009e2:	83 e8 01             	sub    $0x1,%eax
  4009e5:	39 45 f8             	cmp    %eax,-0x8(%rbp)
  4009e8:	0f 8c 4c ff ff ff    	jl     40093a <up_fl+0x36>
  4009ee:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  4009f2:	8b 45 ec             	mov    -0x14(%rbp),%eax
  4009f5:	83 e8 01             	sub    $0x1,%eax
  4009f8:	39 45 fc             	cmp    %eax,-0x4(%rbp)
  4009fb:	0f 8c 2d ff ff ff    	jl     40092e <up_fl+0x2a>
  400a01:	90                   	nop
  400a02:	5d                   	pop    %rbp
  400a03:	c3                   	retq   

0000000000400a04 <down>:
  400a04:	55                   	push   %rbp
  400a05:	48 89 e5             	mov    %rsp,%rbp
  400a08:	89 7d ec             	mov    %edi,-0x14(%rbp)
  400a0b:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  400a0f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  400a16:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
  400a1d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
  400a24:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  400a2b:	e9 c1 00 00 00       	jmpq   400af1 <down+0xed>
  400a30:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
  400a37:	e9 9f 00 00 00       	jmpq   400adb <down+0xd7>
  400a3c:	8b 45 f8             	mov    -0x8(%rbp),%eax
  400a3f:	48 98                	cltq   
  400a41:	48 8d 14 85 00 00 00 	lea    0x0(,%rax,4),%rdx
  400a48:	00 
  400a49:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  400a4d:	48 01 d0             	add    %rdx,%rax
  400a50:	8b 10                	mov    (%rax),%edx
  400a52:	8b 45 f8             	mov    -0x8(%rbp),%eax
  400a55:	48 98                	cltq   
  400a57:	48 83 c0 01          	add    $0x1,%rax
  400a5b:	48 8d 0c 85 00 00 00 	lea    0x0(,%rax,4),%rcx
  400a62:	00 
  400a63:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  400a67:	48 01 c8             	add    %rcx,%rax
  400a6a:	8b 00                	mov    (%rax),%eax
  400a6c:	39 c2                	cmp    %eax,%edx
  400a6e:	7d 67                	jge    400ad7 <down+0xd3>
  400a70:	8b 45 f8             	mov    -0x8(%rbp),%eax
  400a73:	48 98                	cltq   
  400a75:	48 8d 14 85 00 00 00 	lea    0x0(,%rax,4),%rdx
  400a7c:	00 
  400a7d:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  400a81:	48 01 d0             	add    %rdx,%rax
  400a84:	8b 00                	mov    (%rax),%eax
  400a86:	89 45 f4             	mov    %eax,-0xc(%rbp)
  400a89:	8b 45 f8             	mov    -0x8(%rbp),%eax
  400a8c:	48 98                	cltq   
  400a8e:	48 83 c0 01          	add    $0x1,%rax
  400a92:	48 8d 14 85 00 00 00 	lea    0x0(,%rax,4),%rdx
  400a99:	00 
  400a9a:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  400a9e:	48 01 d0             	add    %rdx,%rax
  400aa1:	8b 55 f8             	mov    -0x8(%rbp),%edx
  400aa4:	48 63 d2             	movslq %edx,%rdx
  400aa7:	48 8d 0c 95 00 00 00 	lea    0x0(,%rdx,4),%rcx
  400aae:	00 
  400aaf:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  400ab3:	48 01 ca             	add    %rcx,%rdx
  400ab6:	8b 00                	mov    (%rax),%eax
  400ab8:	89 02                	mov    %eax,(%rdx)
  400aba:	8b 45 f8             	mov    -0x8(%rbp),%eax
  400abd:	48 98                	cltq   
  400abf:	48 83 c0 01          	add    $0x1,%rax
  400ac3:	48 8d 14 85 00 00 00 	lea    0x0(,%rax,4),%rdx
  400aca:	00 
  400acb:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  400acf:	48 01 c2             	add    %rax,%rdx
  400ad2:	8b 45 f4             	mov    -0xc(%rbp),%eax
  400ad5:	89 02                	mov    %eax,(%rdx)
  400ad7:	83 45 f8 01          	addl   $0x1,-0x8(%rbp)
  400adb:	8b 45 ec             	mov    -0x14(%rbp),%eax
  400ade:	2b 45 fc             	sub    -0x4(%rbp),%eax
  400ae1:	83 e8 01             	sub    $0x1,%eax
  400ae4:	39 45 f8             	cmp    %eax,-0x8(%rbp)
  400ae7:	0f 8c 4f ff ff ff    	jl     400a3c <down+0x38>
  400aed:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  400af1:	8b 45 ec             	mov    -0x14(%rbp),%eax
  400af4:	83 e8 01             	sub    $0x1,%eax
  400af7:	39 45 fc             	cmp    %eax,-0x4(%rbp)
  400afa:	0f 8c 30 ff ff ff    	jl     400a30 <down+0x2c>
  400b00:	90                   	nop
  400b01:	5d                   	pop    %rbp
  400b02:	c3                   	retq   

0000000000400b03 <reverse>:
  400b03:	55                   	push   %rbp
  400b04:	48 89 e5             	mov    %rsp,%rbp
  400b07:	89 7d ec             	mov    %edi,-0x14(%rbp)
  400b0a:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  400b0e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  400b15:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
  400b1c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  400b23:	eb 69                	jmp    400b8e <reverse+0x8b>
  400b25:	8b 45 fc             	mov    -0x4(%rbp),%eax
  400b28:	48 98                	cltq   
  400b2a:	48 8d 14 85 00 00 00 	lea    0x0(,%rax,4),%rdx
  400b31:	00 
  400b32:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  400b36:	48 01 d0             	add    %rdx,%rax
  400b39:	8b 00                	mov    (%rax),%eax
  400b3b:	89 45 f8             	mov    %eax,-0x8(%rbp)
  400b3e:	8b 45 ec             	mov    -0x14(%rbp),%eax
  400b41:	2b 45 fc             	sub    -0x4(%rbp),%eax
  400b44:	48 98                	cltq   
  400b46:	48 c1 e0 02          	shl    $0x2,%rax
  400b4a:	48 8d 50 fc          	lea    -0x4(%rax),%rdx
  400b4e:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  400b52:	48 01 d0             	add    %rdx,%rax
  400b55:	8b 55 fc             	mov    -0x4(%rbp),%edx
  400b58:	48 63 d2             	movslq %edx,%rdx
  400b5b:	48 8d 0c 95 00 00 00 	lea    0x0(,%rdx,4),%rcx
  400b62:	00 
  400b63:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  400b67:	48 01 ca             	add    %rcx,%rdx
  400b6a:	8b 00                	mov    (%rax),%eax
  400b6c:	89 02                	mov    %eax,(%rdx)
  400b6e:	8b 45 ec             	mov    -0x14(%rbp),%eax
  400b71:	2b 45 fc             	sub    -0x4(%rbp),%eax
  400b74:	48 98                	cltq   
  400b76:	48 c1 e0 02          	shl    $0x2,%rax
  400b7a:	48 8d 50 fc          	lea    -0x4(%rax),%rdx
  400b7e:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  400b82:	48 01 c2             	add    %rax,%rdx
  400b85:	8b 45 f8             	mov    -0x8(%rbp),%eax
  400b88:	89 02                	mov    %eax,(%rdx)
  400b8a:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  400b8e:	8b 45 ec             	mov    -0x14(%rbp),%eax
  400b91:	89 c2                	mov    %eax,%edx
  400b93:	c1 ea 1f             	shr    $0x1f,%edx
  400b96:	01 d0                	add    %edx,%eax
  400b98:	d1 f8                	sar    %eax
  400b9a:	39 45 fc             	cmp    %eax,-0x4(%rbp)
  400b9d:	7c 86                	jl     400b25 <reverse+0x22>
  400b9f:	90                   	nop
  400ba0:	5d                   	pop    %rbp
  400ba1:	c3                   	retq   

0000000000400ba2 <magic>:
  400ba2:	55                   	push   %rbp
  400ba3:	48 89 e5             	mov    %rsp,%rbp
  400ba6:	89 7d ec             	mov    %edi,-0x14(%rbp)
  400ba9:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  400bad:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  400bb4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  400bbb:	eb 38                	jmp    400bf5 <magic+0x53>
  400bbd:	8b 45 fc             	mov    -0x4(%rbp),%eax
  400bc0:	48 98                	cltq   
  400bc2:	48 8d 14 85 00 00 00 	lea    0x0(,%rax,4),%rdx
  400bc9:	00 
  400bca:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  400bce:	48 01 d0             	add    %rdx,%rax
  400bd1:	8b 00                	mov    (%rax),%eax
  400bd3:	0f af 45 fc          	imul   -0x4(%rbp),%eax
  400bd7:	8b 55 fc             	mov    -0x4(%rbp),%edx
  400bda:	48 63 d2             	movslq %edx,%rdx
  400bdd:	48 8d 0c 95 00 00 00 	lea    0x0(,%rdx,4),%rcx
  400be4:	00 
  400be5:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  400be9:	48 01 ca             	add    %rcx,%rdx
  400bec:	2b 45 ec             	sub    -0x14(%rbp),%eax
  400bef:	89 02                	mov    %eax,(%rdx)
  400bf1:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  400bf5:	8b 45 fc             	mov    -0x4(%rbp),%eax
  400bf8:	3b 45 ec             	cmp    -0x14(%rbp),%eax
  400bfb:	7c c0                	jl     400bbd <magic+0x1b>
  400bfd:	90                   	nop
  400bfe:	5d                   	pop    %rbp
  400bff:	c3                   	retq   

0000000000400c00 <sort_and_display>:
  400c00:	55                   	push   %rbp
  400c01:	48 89 e5             	mov    %rsp,%rbp
  400c04:	48 83 ec 20          	sub    $0x20,%rsp
  400c08:	89 7d fc             	mov    %edi,-0x4(%rbp)
  400c0b:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  400c0f:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  400c13:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
  400c17:	8b 55 fc             	mov    -0x4(%rbp),%edx
  400c1a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  400c1e:	48 89 ce             	mov    %rcx,%rsi
  400c21:	89 d7                	mov    %edx,%edi
  400c23:	ff d0                	callq  *%rax
  400c25:	48 8d 3d 1d 01 00 00 	lea    0x11d(%rip),%rdi        # 400d49 <_IO_stdin_used+0x9>
  400c2c:	b8 00 00 00 00       	mov    $0x0,%eax
  400c31:	e8 9a f8 ff ff       	callq  4004d0 <printf@plt>
  400c36:	c7 05 10 14 20 00 00 	movl   $0x0,0x201410(%rip)        # 602050 <i.2797>
  400c3d:	00 00 00 
  400c40:	eb 3b                	jmp    400c7d <sort_and_display+0x7d>
  400c42:	8b 05 08 14 20 00    	mov    0x201408(%rip),%eax        # 602050 <i.2797>
  400c48:	48 98                	cltq   
  400c4a:	48 8d 14 85 00 00 00 	lea    0x0(,%rax,4),%rdx
  400c51:	00 
  400c52:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  400c56:	48 01 d0             	add    %rdx,%rax
  400c59:	8b 00                	mov    (%rax),%eax
  400c5b:	89 c6                	mov    %eax,%esi
  400c5d:	48 8d 3d e2 00 00 00 	lea    0xe2(%rip),%rdi        # 400d46 <_IO_stdin_used+0x6>
  400c64:	b8 00 00 00 00       	mov    $0x0,%eax
  400c69:	e8 62 f8 ff ff       	callq  4004d0 <printf@plt>
  400c6e:	8b 05 dc 13 20 00    	mov    0x2013dc(%rip),%eax        # 602050 <i.2797>
  400c74:	83 c0 01             	add    $0x1,%eax
  400c77:	89 05 d3 13 20 00    	mov    %eax,0x2013d3(%rip)        # 602050 <i.2797>
  400c7d:	8b 05 cd 13 20 00    	mov    0x2013cd(%rip),%eax        # 602050 <i.2797>
  400c83:	39 45 fc             	cmp    %eax,-0x4(%rbp)
  400c86:	7f ba                	jg     400c42 <sort_and_display+0x42>
  400c88:	bf 0a 00 00 00       	mov    $0xa,%edi
  400c8d:	e8 1e f8 ff ff       	callq  4004b0 <putchar@plt>
  400c92:	90                   	nop
  400c93:	c9                   	leaveq 
  400c94:	c3                   	retq   

0000000000400c95 <fake_puts>:
  400c95:	55                   	push   %rbp
  400c96:	48 89 e5             	mov    %rsp,%rbp
  400c99:	48 83 ec 10          	sub    $0x10,%rsp
  400c9d:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  400ca1:	48 8d 3d b4 00 00 00 	lea    0xb4(%rip),%rdi        # 400d5c <_IO_stdin_used+0x1c>
  400ca8:	e8 33 f8 ff ff       	callq  4004e0 <puts@plt>
  400cad:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  400cb1:	48 89 c7             	mov    %rax,%rdi
  400cb4:	e8 07 f8 ff ff       	callq  4004c0 <strlen@plt>
  400cb9:	c9                   	leaveq 
  400cba:	c3                   	retq   
  400cbb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

0000000000400cc0 <__libc_csu_init>:
  400cc0:	41 57                	push   %r15
  400cc2:	41 56                	push   %r14
  400cc4:	49 89 d7             	mov    %rdx,%r15
  400cc7:	41 55                	push   %r13
  400cc9:	41 54                	push   %r12
  400ccb:	4c 8d 25 36 11 20 00 	lea    0x201136(%rip),%r12        # 601e08 <__frame_dummy_init_array_entry>
  400cd2:	55                   	push   %rbp
  400cd3:	48 8d 2d 36 11 20 00 	lea    0x201136(%rip),%rbp        # 601e10 <__init_array_end>
  400cda:	53                   	push   %rbx
  400cdb:	41 89 fd             	mov    %edi,%r13d
  400cde:	49 89 f6             	mov    %rsi,%r14
  400ce1:	4c 29 e5             	sub    %r12,%rbp
  400ce4:	48 83 ec 08          	sub    $0x8,%rsp
  400ce8:	48 c1 fd 03          	sar    $0x3,%rbp
  400cec:	e8 8f f7 ff ff       	callq  400480 <_init>
  400cf1:	48 85 ed             	test   %rbp,%rbp
  400cf4:	74 20                	je     400d16 <__libc_csu_init+0x56>
  400cf6:	31 db                	xor    %ebx,%ebx
  400cf8:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
  400cff:	00 
  400d00:	4c 89 fa             	mov    %r15,%rdx
  400d03:	4c 89 f6             	mov    %r14,%rsi
  400d06:	44 89 ef             	mov    %r13d,%edi
  400d09:	41 ff 14 dc          	callq  *(%r12,%rbx,8)
  400d0d:	48 83 c3 01          	add    $0x1,%rbx
  400d11:	48 39 dd             	cmp    %rbx,%rbp
  400d14:	75 ea                	jne    400d00 <__libc_csu_init+0x40>
  400d16:	48 83 c4 08          	add    $0x8,%rsp
  400d1a:	5b                   	pop    %rbx
  400d1b:	5d                   	pop    %rbp
  400d1c:	41 5c                	pop    %r12
  400d1e:	41 5d                	pop    %r13
  400d20:	41 5e                	pop    %r14
  400d22:	41 5f                	pop    %r15
  400d24:	c3                   	retq   
  400d25:	90                   	nop
  400d26:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  400d2d:	00 00 00 

0000000000400d30 <__libc_csu_fini>:
  400d30:	f3 c3                	repz retq 

Disassembly of section .fini:

0000000000400d34 <_fini>:
  400d34:	48 83 ec 08          	sub    $0x8,%rsp
  400d38:	48 83 c4 08          	add    $0x8,%rsp
  400d3c:	c3                   	retq   
