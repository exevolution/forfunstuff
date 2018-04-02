Enum Suit
{
    Clubs
    Hearts
    Spades
    Diamonds
}

Enum Rank
{
    Ace = 1
    Two = 2
    Three = 3
    Four = 4
    Five = 5
    Six = 6
    Seven = 7
    Eight = 8
    Nine = 9
    Ten = 10
    Jack = 11
    Queen = 12
    King = 13
}

Class Card
{
    [Int]$Value
    [String]$Rank
    [String]$Suit
    [Switch]$Revealed = $False
}

Function New-Hands
{
    $Script:PlayerHand | ForEach-Object {If ($_.Revealed){$_.Revealed = $True}}
    $Script:DiscardPile.Add($Script:PlayerHand) | Out-Null
    $Script:DealerHand | ForEach-Object {If ($_.Revealed){$_.Revealed = $True}}
    $Script:DiscardPile.Add($Script:DealerHand) | Out-Null
    $Script:PlayerHand = New-Object System.Collections.ArrayList
    $Script:DealerHand = New-Object System.Collections.ArrayList
    Write-Host "All hands discarded"
}

Function Build-DeckOfCards
{
    [CmdletBinding()]
    Param([Parameter(Position=0)][ValidateRange(1,6)][Int]$NumberOfDecks = 1)

    $Script:Deck = New-Object System.Collections.ArrayList
    $Script:DiscardPile = New-Object System.Collections.ArrayList
    Write-Host "Building deck of playing cards from $NumberOfDecks decks."
    ForEach ($Rank in [Enum]::GetValues([Rank]))
    {
        ForEach ($Suit in [Enum]::GetValues([Suit]))
        {
            For ($i = 0; $i -lt $NumberOfDecks; $i++)
            {
                $Card = [Card]::new()
                If ($Rank -eq "Ace")
                {$Card.Value = 11}
                ElseIf ($Rank -eq "Jack" -or $Rank -eq "Queen" -or $Rank -eq "King")
                {$Card.Value = 10}
                Else
                {$Card.Value = [Int]$Rank}

                $Card.Rank = [Rank]$Rank
                $Card.Suit = [Suit]$Suit

                Write-Verbose "Added $($Card.Rank) of $($Card.Suit)"
                $Script:Deck.Add($Card) | Out-Null
            }
        }
    }
}

Function Draw-RandomCard
{
    [CmdletBinding()]
    Param(
        [Parameter(Position=0)][ValidateRange(1,7)][Int]$NumberOfCards = 1,
        [Parameter(Mandatory=$True,Position=1)][ValidateSet("Player","Dealer")][String]$Hand,
        [Parameter(Position=2)][Switch]$Reveal = $False
    )

    Switch($Hand)
    {
        "Player"
        {
            For ($i = 0; $i -lt $NumberOfCards; $i++)
            {
                Write-Host "The Player draws one card"
                $Card = $Script:Deck | Get-Random
                If ($Reveal -eq $True)
                {
                    $Card.Revealed = $True
                    $Card | Format-Table
                }
                Else
                {
                    Write-Host "`nThe card has been placed face down`n"
                }
                $Script:PlayerHand.Add($Card) | Out-Null
                $Script:Deck.Remove($Card)
                Write-Host "$($Script:Deck.Count) cards remaining in deck."
            }
        }
        "Dealer"
        {
            For ($i = 0; $i -lt $NumberOfCards; $i++)
            {
                Write-Host "The Dealer draws one card"
                $Card = $Script:Deck | Get-Random
                If ($Reveal -eq $True)
                {
                    $Card.Revealed = $True
                    $Card | Format-Table
                }
                Else
                {
                    Write-Host "`nThe card has been placed face down!`n"
                }
                $Script:DealerHand.Add($Card) | Out-Null
                $Script:Deck.Remove($Card)
                Write-Host "$($Script:Deck.Count) cards remaining in deck."
            }
        }
    }
}

Function Sort-PlayerHand
{
    [CmdletBinding()]
    Param([Parameter(Position=0)][ValidateSet("Rank","Suit")][String]$Order = "Suit")

    $Script:PlayerHand = $Script:PlayerHand | Sort-Object $Order
    Show-Hand -Hand Player -ShowHidden
}

Function Show-Hand
{
    [CmdletBinding()]
    Param([Parameter(Position=0)][ValidateSet("Player","Dealer","All")][String]$Hand = "Player",
    [Parameter(Position=1)][Switch]$ShowHidden = $False)

    Switch ($Hand)
    {
        "Player"
        {
            Write-Host "Player Hand:"
            If ($ShowHidden -eq $True)
            {
                $Script:PlayerHand | Format-Table
            }
            Else
            {
                ForEach ($Card in $Script:PlayerHand)
                {
                    If ($Card.Revealed -eq $True)
                    {
                        $Card | Format-Table
                    }
                    Else
                    {
                        Write-Host "Face down card"
                    }
                }
            }
            $PlayerSum = $Script:PlayerHand | Measure-Object Value -Sum | Select-Object Sum
            Do
            {
                If ($PlayerSum.Sum -eq 21)
                {
                    Write-Host "BLACKJACK!" -ForegroundColor Green
                    Break
                }
                ElseIf ($PlayerSum.Sum -gt 21 -and $Script:PlayerHand.Rank -contains "Ace")
                {
                    $Script:PlayerHand | Where-Object {$_.Rank -eq "Ace" -and $_.Value -eq 11} | Select-Object -First 1 | ForEach {$_.Value = 1}
                    Continue
                }
                ElseIf ($PlayerSum.Sum -gt 21)
                {
                    Write-Host "BUST! You lose!" -ForegroundColor Red
                    Break
                }
                Break
            }
            Until ($Script:PlayerHand -le 21)
        }
        "Dealer"
        {
            Write-Host "Dealer Hand:"
            If ($ShowHidden -eq $True)
            {
                $Script:DealerHand | Format-Table
            }
            Else
            {
                ForEach ($Card in $Script:DealerHand)
                {
                    If ($Card.Revealed -eq $True)
                    {
                        $Card | Format-Table
                    }
                    Else
                    {
                        Write-Host "Face down card"
                    }
                }
            }
        }
        "All"
        {
            Write-Host "Player Hand:"
            If ($ShowHidden -eq $True)
            {
                $Script:PlayerHand | Format-Table
            }
            Else
            {
                ForEach ($Card in $Script:PlayerHand)
                {
                    If ($Card.Revealed -eq $True)
                    {
                        $Card | Format-Table
                    }
                    Else
                    {
                        Write-Host "Face down card"
                    }
                }
            }
            If ($ShowHidden -eq $True)
            {
                $Script:DealerHand | Format-Table
            }
            Else
            {
                ForEach ($Card in $Script:DealerHand)
                {
                    If ($Card.Revealed -eq $True)
                    {
                        $Card | Format-Table
                    }
                    Else
                    {
                        Write-Host "Face down card"
                    }
                }
            }
        }
    }

}

Function Show-DiscardPile
{
    Write-Host "Showing discarded cards"
    $Script:DiscardPile | Format-Table
}

Function Start-BlackJack
{
    [CmdletBinding()]
    Param([Parameter(Position=0)][ValidateRange(1,6)][Int]$Decks = 6)

    Begin
    {
        Write-Host "Starting Blackjack with $Decks decks."
        Build-DeckOfCards -NumberOfDecks $Decks
        Draw-RandomCard -Hand Player -Reveal
        Draw-RandomCard -Hand Dealer -Reveal
        Draw-RandomCard -Hand Player -Reveal
        Draw-RandomCard -Hand Dealer
    }
    Process
    {

    }
}
Build-DeckOfCards -NumberOfDecks 6
New-Hands

# Important Variables and Cmdlets
# Build-DeckOfCards -NumberOfDecks 4
# Draw-RandomCard -NumberOfCards 7
# $PlayerHand
# $Deck
