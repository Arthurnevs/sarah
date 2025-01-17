module Medico where

import GHC.Show (Show)
import Text.Read (Read)
import System.IO
import Data.Char

import System.Directory
import Utils ( unSplit, wordsWhen )

data Medico = Medico{
    crm :: String, 
    nome :: String,
    especialidade :: String
} deriving (Show,Read)

adcionaMedico :: String -> String -> String -> Medico
adcionaMedico crmMedico nomeMedico especialidadeMedico = (Medico{crm = crmMedico, nome = nomeMedico, especialidade = especialidadeMedico})

escreverMedico::Medico.Medico -> IO()
escreverMedico  medico = do
    appendFile "../db/medicos.txt" (Medico.crm medico ++ "," ++ Medico.nome medico ++ ","  ++ Medico.especialidade medico++ "\n")
    return ()

listaDeMedicos ::  IO()
listaDeMedicos  = do
    handle <- openFile "../db/medicos.txt" ReadMode  
    contents <- hGetContents handle
    putStr  contents
    hClose handle

removeMedicoPorCrm :: String -> IO()
removeMedicoPorCrm crmDoMedico = do
    handle <- openFile "../db/medicos.txt" ReadMode  
    tempdir <- getTemporaryDirectory  
    (tempName, tempHandle) <- openTempFile tempdir "temp"  
    contents <- hGetContents handle
    let listaComMedicos = lines contents
    let listaLista = map (\ x -> wordsWhen (==',') x) listaComMedicos
    let medicosResultante = filter (filtraMedicosCrm crmDoMedico) listaLista
    let newContents = listaDeListasToLista medicosResultante
    hPutStr tempHandle $ unlines newContents  
    hClose handle  
    hClose tempHandle  
    removeFile "../db/medicos.txt"  
    renameFile tempName "../db/medicos.txt" 

editaMedicoPorCrm :: String -> String -> String -> IO()
editaMedicoPorCrm crmMedico novoNome novaEspecialidade = do
    removeMedicoPorCrm crmMedico
    escreverMedico (adcionaMedico crmMedico novoNome novaEspecialidade)

filtraMedicosCrm :: String -> [String] -> Bool 
filtraMedicosCrm _ [] = False
filtraMedicosCrm crmFiltro (x:xs) = x /= crmFiltro 


listaDeListasToLista :: [[String]] -> [String]
listaDeListasToLista [] = []
listaDeListasToLista (x:xs) = (unSplit  x) : listaDeListasToLista xs


