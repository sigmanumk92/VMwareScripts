Function Prepare-CIHost { 
    Param ( 
        $Username, 
        $Password, 
        $CIHost 
    ) 
    $Search = Search-cloud -QueryType Host -Name $CIHost 
    $HostView = Get-CIView -SearchResult $Search 
    $HostView.Prepare($password, $username) 
}