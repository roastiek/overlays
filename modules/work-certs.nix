{ config, lib, pkgs, ... }:
{
  security.pki.certificateFiles = [
    ./cert/seznamca-kancelar-issuing.crt
    ./cert/seznamca-kancelar-root.crt
    ./cert/seznamca-logy.crt
    ./cert/seznamca-root.crt
    ./cert/seznamca-server.crt
    ./cert/seznam-kancelar-root-ca-2020.crt
    ./cert/seznam-kancelar-issuing-ca-2021.crt
    ./cert/seznam-rootca-2022.crt
  ];
}