module Convenios where

import Text.Read (Read)
import System.IO
import System.Directory
import qualified Data.Text as T
import qualified Data.List as L
import Util

data Convenios = Convenios{
    cnpj :: String,
    nome :: String,
    desconto :: Integer
} deriving (Show, Read)

getCnpj :: Convenios -> String
getCnpj Convenios {cnpj = cnpj} = cnpj

getNome :: Convenios -> String
getNome Convenios {nome = nome} = nome

getDesconto :: Convenios -> Integer
getDesconto Convenios {desconto = desconto} = desconto

listaConvenios :: IO()
listaConvenios = do
    handle <- openFile "plp-funcional/Dados.txt" ReadMode
    texto <- hGetContents handle
    putStr texto
    hClose handle

menuAdd :: IO()
menuAdd = do
    putStrLn "CNPJ do convenio sem (.) e sem (/):"
    cnpj <- getLine
    putStrLn "Nome do convenio:"
    nome <- getLine
    putStrLn "Desconto concedido:"
    desconto <- getLine
    escreverConvenio (adicionaConvenio cnpj nome (read desconto))

adicionaConvenio :: String -> String -> Integer -> Convenios
adicionaConvenio cnpj nome desconto = Convenios{cnpj = cnpj, nome = nome, desconto = desconto}

escreverConvenio :: Convenios.Convenios -> IO()
escreverConvenio convenio = do 
    appendFile "plp-funcional/Dados.txt" ((Convenios.cnpj convenio) ++ "," ++ Convenios.nome convenio ++ "," ++ show(Convenios.desconto convenio) ++ "\n")
    return ()

menuRemover :: IO()
menuRemover = do
    putStrLn "CNPJ do convenio a ser removido sem (.) e sem (/):"
    cnpj <- getLine
    if trimAllBlankSpaces cnpj == ""
    then
        putStr "CNPJ invalido!"
    else
        removeConvenio cnpj

removeConvenio:: String -> IO()
removeConvenio cnpj = do
    handle <- openFile "plp-funcional/Dados.txt" ReadMode
    tempdir <- getTemporaryDirectory
    (tempName, tempHandle) <- openTempFile tempdir "temp"
    contents <- hGetContents handle
    let listaComConvenios = lines contents
    let conveniosResultantes = filter(\x -> not(contains x (toUpperCaseAndStrip cnpj))) (map toUpperCaseAndStrip listaComConvenios)
    let conveniosFormatados = map(T.unpack . T.toTitle . T.pack) conveniosResultantes
    hPutStr tempHandle $ unlines conveniosFormatados
    hClose handle
    hClose tempHandle
    removeFile "plp-funcional/Dados.txt"
    renameFile tempName "plp-funcional/Dados.txt"

menuEditar :: IO()
menuEditar = do
    putStrLn "CNPJ do convenio a ser editado:"
    cnpj <- getLine
    putStrLn "Novo nome do convenio:"
    novoNome <- getLine
    putStrLn "Novo desconto do convenio:"
    desconto <- getLine
    if trimAllBlankSpaces cnpj == ""
    then
        putStr "CNPJ invalido!"
    else
        editarConvenio cnpj novoNome (read desconto)

editarConvenio :: String -> String ->Integer -> IO()
editarConvenio  cnpj nome desconto = do
    removeConvenio cnpj
    escreverConvenio (adicionaConvenio cnpj nome (desconto))

main :: IO()
main = do
    putStrLn "1 - Cadastrar Convenio"
    putStrLn "2 - Remover Convenio"
    putStrLn "3 - Editar Convenio"
    putStrLn "4 - Listar Convenios"

    opcao <- getLine
    case opcao of 
        "1" -> menuAdd
        "2" -> menuRemover
        "3" -> menuEditar
        "4" -> listaConvenios