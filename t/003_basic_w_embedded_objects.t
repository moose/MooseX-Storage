use strict;
use warnings;

use Test::More tests => 58;
use Test::Deep;

BEGIN {
    use_ok('MooseX::Storage');
}

=pod

This test checks the single level
expansion and collpasing of the
ArrayRef and HashRef type handlers.

=cut

{
    package Bar;
    use Moose;
    use MooseX::Storage;

    with Storage;

    has 'number' => (is => 'ro', isa => 'Int');

    package Foo;
    use Moose;
    use MooseX::Storage;

    with Storage;

    has 'bars' => (
        is  => 'ro',
        isa => 'ArrayRef'
    );

    package Baz;
    use Moose;
    use MooseX::Storage;

    with Storage;

    has 'bars' => (
        is  => 'ro',
        isa => 'HashRef'
    );

    package Qux;
    use Moose;
    use MooseX::Storage;

    with Storage;

    has foos_aa => ( is => 'ro', isa => 'ArrayRef[ArrayRef[Foo]]' );
    has foos_ah => ( is => 'ro', isa => 'ArrayRef[HashRef[Foo]]' );
    has foos_ha => ( is => 'ro', isa => 'HashRef[ArrayRef[Foo]]' );
    has foos_hh => ( is => 'ro', isa => 'HashRef[HashRef[Foo]]' );

    has bazs_aa => ( is => 'ro', isa => 'ArrayRef[ArrayRef[Baz]]' );
    has bazs_ah => ( is => 'ro', isa => 'ArrayRef[HashRef[Baz]]' );
    has bazs_ha => ( is => 'ro', isa => 'HashRef[ArrayRef[Baz]]' );
    has bazs_hh => ( is => 'ro', isa => 'HashRef[HashRef[Baz]]' );
}

{
    my $foo = Foo->new(
        bars => [ map { Bar->new(number => $_) } (1 .. 10) ]
    );
    isa_ok( $foo, 'Foo' );

    cmp_deeply(
        $foo->pack,
        {
            __CLASS__ => 'Foo',
            bars      => [
                map {
                  {
                      __CLASS__ => 'Bar',
                      number    => $_,
                  }
                } (1 .. 10)
            ],
        },
        '... got the right frozen class'
    );
}

{
    my $foo = Foo->unpack(
        {
            __CLASS__ => 'Foo',
            bars      => [
                map {
                  {
                      __CLASS__ => 'Bar',
                      number    => $_,
                  }
                } (1 .. 10)
            ],
        }
    );
    isa_ok( $foo, 'Foo' );

    foreach my $i (1 .. scalar @{$foo->bars}) {
        isa_ok($foo->bars->[$i - 1], 'Bar');
        is($foo->bars->[$i - 1]->number, $i, "... got the right number ($i) in the Bar in Foo");
    }
}

{
    my $baz = Baz->new(
        bars => { map { ($_ => Bar->new(number => $_)) } (1 .. 10) }
    );
    isa_ok( $baz, 'Baz' );

    cmp_deeply(
        $baz->pack,
        {
            __CLASS__ => 'Baz',
            bars      => {
                map {
                  ($_ => {
                      __CLASS__ => 'Bar',
                      number    => $_,
                  })
                } (1 .. 10)
            },
        },
        '... got the right frozen class'
    );
}

{
    my $baz = Baz->unpack(
        {
            __CLASS__ => 'Baz',
            bars      => {
                map {
                  ($_ => {
                      __CLASS__ => 'Bar',
                      number    => $_,
                  })
                } (1 .. 10)
            },
        }
    );
    isa_ok( $baz, 'Baz' );

    foreach my $k (keys %{$baz->bars}) {
        isa_ok($baz->bars->{$k}, 'Bar');
        is($baz->bars->{$k}->number, $k, "... got the right number ($k) in the Bar in Baz");
    }
}


{
    my $qux = Qux->new(
        foos_aa => [
            map {
                [
                    map {
                        Foo->new(
                            bars => [
                                map { Bar->new( number => $_ ) } ( 1 .. 10 )
                            ]
                            )
                    } ( 1 .. 10 )
                ]
            } ( 1 .. 10 )
        ],

        foos_ah => [
            map {
                {
                    map {
                        $_ => Foo->new(
                            bars => [
                                map { Bar->new( number => $_ ) } ( 1 .. 10 )
                            ]
                            )
                        } ( 1 .. 10 )
                }
            } ( 1 .. 10 )
        ],

        foos_ha => {
            map {
                $_ => [
                    map {
                        Foo->new(
                            bars => [
                                map { Bar->new( number => $_ ) } ( 1 .. 10 )
                            ]
                            )
                    } ( 1 .. 10 )
                    ]
            } ( 1 .. 10 )
        },

        foos_hh => {
            map {
                $_ => {
                    map {
                        $_ => Foo->new(
                            bars => [
                                map { Bar->new( number => $_ ) } ( 1 .. 10 )
                            ]
                            )
                    } ( 1 .. 10 )
                    }
            } ( 1 .. 10 )
        },

        bazs_aa => [
            map {
                [
                    map {
                        Baz->new(
                            bars => {
                                map { ( $_ => Bar->new( number => $_ ) ) }
                                    ( 1 .. 10 )
                            }
                            )
                    } ( 1 .. 10 )
                ]
            } ( 1 .. 10 )
        ],

        bazs_ah => [
            map {
                {
                    map {
                        $_ => Baz->new(
                            bars => {
                                map { ( $_ => Bar->new( number => $_ ) ) }
                                    ( 1 .. 10 )
                            }
                            )
                        } ( 1 .. 10 )
                }
            } ( 1 .. 10 )
        ],

        bazs_ha => {
            map {
                $_ => [
                    map {
                        Baz->new(
                            bars => {
                                map { ( $_ => Bar->new( number => $_ ) ) }
                                    ( 1 .. 10 )
                            }
                            )
                    } ( 1 .. 10 )
                    ]
            } ( 1 .. 10 )
        },

        bazs_hh => {
            map {
                $_ => {
                    map {
                        $_ => Baz->new(
                            bars => {
                                map { ( $_ => Bar->new( number => $_ ) ) }
                                    ( 1 .. 10 )
                            }
                            )
                    } ( 1 .. 10 )
                    }
            } ( 1 .. 10 )
        },

    );
    isa_ok( $qux, 'Qux' );

    cmp_deeply(
        $qux->pack,
        {
            __CLASS__ => 'Qux',
            foos_aa   => [
                map {
                    [
                        map {
                            {
                                __CLASS__ => 'Foo',
                                bars      => [
                                    map {
                                        {
                                            __CLASS__ => 'Bar',
                                            number    => $_,
                                        }
                                    } ( 1 .. 10 )
                                ],
                            }
                        } ( 1 .. 10 )
                    ]
                } ( 1 .. 10 )
            ],

            foos_ah => [
                map {
                    {
                        map {
                            $_ => {
                                __CLASS__ => 'Foo',
                                bars      => [
                                    map {
                                        {
                                            __CLASS__ => 'Bar',
                                            number    => $_,
                                        }
                                    } ( 1 .. 10 )
                                ],
                                }
                            } ( 1 .. 10 )
                    }
                } ( 1 .. 10 )
            ],

            foos_ha => {
                map {
                    $_ => [
                        map {
                            {
                                __CLASS__ => 'Foo',
                                bars      => [
                                    map {
                                        {
                                            __CLASS__ => 'Bar',
                                            number    => $_,
                                        }
                                    } ( 1 .. 10 )
                                ],
                            }
                        } ( 1 .. 10 )
                        ]
                } ( 1 .. 10 )
            },

            foos_hh => {
                map {
                    $_ => {
                        map {
                            $_ => {
                                __CLASS__ => 'Foo',
                                bars      => [
                                    map {
                                        {
                                            __CLASS__ => 'Bar',
                                            number    => $_,
                                        }
                                    } ( 1 .. 10 )
                                ],
                                }
                        } ( 1 .. 10 )
                        }
                } ( 1 .. 10 )
            },

            bazs_aa => [
                map {
                    [
                        map {
                            {
                                __CLASS__ => 'Baz',
                                bars      => {
                                    map {
                                        (
                                            $_ => {
                                                __CLASS__ => 'Bar',
                                                number    => $_,
                                            }
                                            )
                                    } ( 1 .. 10 )
                                },
                            }
                        } ( 1 .. 10 )
                    ]
                } ( 1 .. 10 )
            ],

            bazs_ah => [
                map {
                    {
                        map {
                            $_ => {
                                __CLASS__ => 'Baz',
                                bars      => {
                                    map {
                                        (
                                            $_ => {
                                                __CLASS__ => 'Bar',
                                                number    => $_,
                                            }
                                            )
                                    } ( 1 .. 10 )
                                },
                                }
                            } ( 1 .. 10 )
                    }
                } ( 1 .. 10 )
            ],

            bazs_ha => {
                map {
                    $_ => [
                        map {
                            {
                                __CLASS__ => 'Baz',
                                bars      => {
                                    map {
                                        (
                                            $_ => {
                                                __CLASS__ => 'Bar',
                                                number    => $_,
                                            }
                                            )
                                    } ( 1 .. 10 )
                                },
                            }
                        } ( 1 .. 10 )
                        ]
                } ( 1 .. 10 )
            },

            bazs_hh => {
                map {
                    $_ => {
                        map {
                            $_ => {
                                __CLASS__ => 'Baz',
                                bars      => {
                                    map {
                                        (
                                            $_ => {
                                                __CLASS__ => 'Bar',
                                                number    => $_,
                                            }
                                            )
                                    } ( 1 .. 10 )
                                },
                                }
                        } ( 1 .. 10 )
                        }
                } ( 1 .. 10 )
            },
        },
        '... got the right frozen class'
    );
}

{
    my $qux = Qux->unpack(
        {
            __CLASS__ => 'Qux',
            foos_aa   => [
                map {
                    [
                        map {
                            {
                                __CLASS__ => 'Foo',
                                bars      => [
                                    map {
                                        {
                                            __CLASS__ => 'Bar',
                                            number    => $_,
                                        }
                                    } ( 1 .. 10 )
                                ],
                            }
                        } ( 1 .. 10 )
                    ]
                } ( 1 .. 10 )
            ],

            foos_ah => [
                map {
                    {
                        map {
                            $_ => {
                                __CLASS__ => 'Foo',
                                bars      => [
                                    map {
                                        {
                                            __CLASS__ => 'Bar',
                                            number    => $_,
                                        }
                                    } ( 1 .. 10 )
                                ],
                                }
                            } ( 1 .. 10 )
                    }
                } ( 1 .. 10 )
            ],

            foos_ha => {
                map {
                    $_ => [
                        map {
                            {
                                __CLASS__ => 'Foo',
                                bars      => [
                                    map {
                                        {
                                            __CLASS__ => 'Bar',
                                            number    => $_,
                                        }
                                    } ( 1 .. 10 )
                                ],
                            }
                        } ( 1 .. 10 )
                        ]
                } ( 1 .. 10 )
            },

            foos_hh => {
                map {
                    $_ => {
                        map {
                            $_ => {
                                __CLASS__ => 'Foo',
                                bars      => [
                                    map {
                                        {
                                            __CLASS__ => 'Bar',
                                            number    => $_,
                                        }
                                    } ( 1 .. 10 )
                                ],
                                }
                        } ( 1 .. 10 )
                        }
                } ( 1 .. 10 )
            },

            bazs_aa => [
                map {
                    [
                        map {
                            {
                                __CLASS__ => 'Baz',
                                bars      => {
                                    map {
                                        (
                                            $_ => {
                                                __CLASS__ => 'Bar',
                                                number    => $_,
                                            }
                                            )
                                    } ( 1 .. 10 )
                                },
                            }
                        } ( 1 .. 10 )
                    ]
                } ( 1 .. 10 )
            ],

            bazs_ah => [
                map {
                    {
                        map {
                            $_ => {
                                __CLASS__ => 'Baz',
                                bars      => {
                                    map {
                                        (
                                            $_ => {
                                                __CLASS__ => 'Bar',
                                                number    => $_,
                                            }
                                            )
                                    } ( 1 .. 10 )
                                },
                                }
                            } ( 1 .. 10 )
                    }
                } ( 1 .. 10 )
            ],

            bazs_ha => {
                map {
                    $_ => [
                        map {
                            {
                                __CLASS__ => 'Baz',
                                bars      => {
                                    map {
                                        (
                                            $_ => {
                                                __CLASS__ => 'Bar',
                                                number    => $_,
                                            }
                                            )
                                    } ( 1 .. 10 )
                                },
                            }
                        } ( 1 .. 10 )
                        ]
                } ( 1 .. 10 )
            },

            bazs_hh => {
                map {
                    $_ => {
                        map {
                            $_ => {
                                __CLASS__ => 'Baz',
                                bars      => {
                                    map {
                                        (
                                            $_ => {
                                                __CLASS__ => 'Bar',
                                                number    => $_,
                                            }
                                            )
                                    } ( 1 .. 10 )
                                },
                                }
                        } ( 1 .. 10 )
                        }
                } ( 1 .. 10 )
            },
        }
    );
    isa_ok( $qux, 'Qux' );


    my $deep_check_isa;
    $deep_check_isa = sub {
        my ($what) = @_;

        if ( ref $what eq 'HASH' ) {
            subtest 'HASH' => sub {
                foreach my $k ( keys %{$what} ) {
                    $deep_check_isa->( $what->{$k} );
                }
            };
        }
        elsif ( ref $what eq 'ARRAY' ) {
            subtest 'ARRAY' => sub {
                foreach my $i ( 1 .. scalar @{$what} ) {
                    $deep_check_isa->( $what->[ $i - 1 ] );
                }
            };
        }
        elsif ( ref $what eq 'Foo' ) {
            foreach my $i ( 1 .. scalar @{ $what->bars } ) {
                isa_ok( $what->bars->[ $i - 1 ], 'Bar' );
                is( $what->bars->[ $i - 1 ]->number,
                    $i, "... got the right number ($i) in the Bar" );
            }
        }
        elsif ( ref $what eq 'Baz' ) {
            foreach my $k ( keys %{ $what->bars } ) {
                isa_ok( $what->bars->{$k}, 'Bar' );
                is( $what->bars->{$k}->number,
                    $k, "... got the right number ($k) in the Bar" );
            }
        }
    };

    for my $test (
        'foos_aa', 'foos_ah', 'foos_ha', 'foos_hh',
        'bazs_aa', 'bazs_ah', 'bazs_ha', 'bazs_hh',
        )
    {
        subtest $test => sub { $deep_check_isa->( $qux->$test ) };
    }
}
