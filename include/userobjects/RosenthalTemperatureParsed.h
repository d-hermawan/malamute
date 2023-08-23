#pragma once

#include "libmesh/mesh_tools.h"
#include "GeneralUserObject.h"

class Function;

class RosenthalTemperatureParsed : public GeneralUserObject
{
public:
    static InputParameters validParams();

    RosenthalTemperatureParsed(const InputParameters & parameters);

    virtual void initialize() final {}
    virtual void execute() final {}
    virtual void finalize() final {}

    virtual Real thermal_conductivity() const;
    virtual Real density() const;
    virtual Real specific_heat() const;
    virtual Real power() const;
    virtual Real melting_temp() const;
    virtual Real ambient_temp() const;
    virtual Real maximum_temp() const;


    virtual Real value(const Point & p) const;

    virtual Real spatialValue(const Point & p) const;

protected:
    Real _kappa;
    Real _rho;
    Real _cp;
    Real _Q;
    const Function & _Vx;
    const Function & _Vy;
    const Function & _x0;
    const Function & _y0;
    Real _Tm;
    Real _To;
    Real _Tmax;
};